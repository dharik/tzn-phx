defmodule TznWeb.SchoolAdmin.ApiController do
  use TznWeb, :controller

  plug :load_profiles
  plug :load_base_data
  plug Accent.Plug.Response, json_codec: Jason, default_case: Accent.Case.Camel

  alias Tzn.Repo

  def handle(conn, %{"query" => "dashboard"}) do
    data = %{
      my_name: conn.assigns.current_user.school_admin_profile.name,
      cohorts: Enum.map(conn.assigns.data, fn pod_group ->
        %{
          id: pod_group.id,
          name: pod_group.name,
          students: Enum.map(pod_group.pods, fn pod ->
            %{
              id: pod.id,
              name: pod.mentee.name,
              mentor_name: pod.mentor.name,
              first_meeting_with_mentor: pod.timesheet_entries |> Enum.sort_by(& &1.id) |> List.first(%{}) |> Map.get(:started_at),
              most_recent_meeting_with_mentor: pod.timesheet_entries |> Enum.sort_by(& &1.id) |> List.last(%{}) |> Map.get(:started_at),
              hours_mentored: pod.hour_counts.hours_used |> Number.Conversion.to_float() |> Float.round(2)
            }
          end),
          school_admins: Enum.map(pod_group.school_admins, fn sa ->
            %{
              name: sa.name
            }
          end)
        }
      end),
      cohort_stats: %{
        num_students: Tzn.PodGroupReporting.num_students(conn.assigns.data),
        hours_mentored: Tzn.PodGroupReporting.hours_mentored(conn.assigns.data)
      }
    }

    json(conn, data)
  end

  def handle(conn, %{"query" => "student_timeline_list"}) do
    data = Enum.map(conn.assigns.data, fn pod_group ->
      %{
        name: pod_group.name,
        students: Enum.map(pod_group.pods, fn pod ->
          %{
            id: pod.id,
            name: pod.mentee.name
          }
        end)
      }
    end)

    json(conn, data)
  end

  def handle(conn, %{"query" => "student_highlights"}) do
    highlights = my_pods(conn)
      |> Enum.map(fn pod ->
        h = Tzn.PodGroupReporting.student_highlights(pod)

        description = cond do
          h.consecutive_missed_sessions > 1 ->
            "#{pod.mentee.name} has missed their last #{h.consecutive_missed_sessions} sessions"

            h.hours_mentored_hit_10_at ->
            "#{pod.mentee.name} has received over 10 hours of 1:1 mentorship!"

            h.hours_mentored_hit_5_at ->
            "#{pod.mentee.name} has received over 5 hours of 1:1 mentorship!"

            h.missed_sessions_last_30_days > 0 ->
            "#{pod.mentee.name} has missed #{h.missed_sessions_last_30_days} sessions in the last month"

          Tzn.Util.within_n_days_ago(h.onboarded_at, 30) ->
            "#{pod.mentee.name} recently completed their onboarding form"

          true -> nil
        end

        %{
          description: description,
          student_id: pod.id
        }
      end)
      |> Enum.reject(& is_nil(&1.description))
      |> Enum.shuffle()
      |> Enum.take(3)

    conn |> json(highlights)
  end

  def handle(conn, %{"query" => "student_timeline", "student_id" => pod_id} = params) do
    pod = Tzn.Pods.get_pod!(pod_id)
    pod_timeline = Tzn.Timelines.get_or_create_timeline(pod)
    events = Tzn.Timelines.aggregate_calendar_events(pod_timeline)
    sort = Map.get(params, "sort", "asc")
    include_past = Map.get(params, "include_past", "n")
    limit = Map.get(params, "limit", 0)
    limit = if is_binary(limit) do
      String.to_integer(limit)
    else
      limit
    end
    events = if include_past == "y" do
      events
    else
      Enum.reject(events, fn e ->
        Timex.before?(e.date, Timex.now())
      end)
    end

    events = if sort == "asc" do
      Enum.sort_by(events, fn e -> e.date end, {:asc, Date})
    else
      Enum.sort_by(events, fn e -> e.date end, {:desc, Date})
    end

    events = if limit && limit > 0 do
      Enum.take(events, limit)
    else
      events
    end

    events = Enum.map(events, fn event ->
      case event do
        %{calendar: calendar, calendar_event: calendar_event} ->
          %{
            year: event.date.year,
            month: event.date.month,
            month_name: Timex.month_name(event.date.month),
            month_shortname: Timex.month_shortname(event.date.month),
            day: event.date.day,
            title: calendar_event.name,
            description: calendar_event.description,
            completed: event.completed,
            hidden: event.hidden
          }
        %{todo: todo} ->
          %{
            year: event.date.year,
            month: event.date.month,
            month_name: Timex.month_name(event.date.month),
            month_shortname: Timex.month_shortname(event.date.month),
            day: event.date.day,
            title: "TODO",
            description: todo.todo_text,
            completed: event.completed,
            hidden: event.hidden
          }
        %{mentor_timeline_event: mte} ->
          %{
            year: event.date.year,
            month: event.date.month,
            month_name: Timex.month_name(event.date.month),
            month_shortname: Timex.month_shortname(event.date.month),
            day: event.date.day,
            title: nil,
            description: mte.notes,
            completed: event.completed,
            hidden: event.hidden
          }
      end
    end)

    conn |> json(events)
  end

  def handle(conn, %{"query" => "general_timeline"} = params) do
    sort = Map.get(params, "sort", "asc")
    include_past = Map.get(params, "include_past", "n")
    limit = Map.get(params, "limit", 0)
    limit = if is_binary(limit) do
      String.to_integer(limit)
    else
      limit
    end


    events =  Tzn.Timelines.general_calendar_events()
    events = if include_past == "y" do
      events
    else
      Enum.reject(events, fn e ->
        Timex.before?(e.date, Timex.now())
      end)
    end

    events = if sort == "asc" do
      Enum.sort_by(events, fn e -> e.date end, {:asc, Date})
    else
      Enum.sort_by(events, fn e -> e.date end, {:desc, Date})
    end

    events = if limit && limit > 0 do
      Enum.take(events, limit)
    else
      events
    end

    events = Enum.map(events, fn event ->
        %{
          year: event.date.year,
          month: event.date.month,
          month_name: Timex.month_name(event.date.month),
          month_shortname: Timex.month_shortname(event.date.month),
          day: event.date.day,
          title: event.calendar_event.name,
          description: event.calendar_event.description,
          completed: event.completed,
          hidden: event.hidden
        }
      end)

    conn |> json(events)
  end

  def handle(conn, %{"query" => "student", "student_id" => pod_id}) do
    pod_id = if is_binary(pod_id) do
      String.to_integer(pod_id)
    else
      pod_id
    end

    pod = Enum.find(my_pods(conn), nil, & &1.id == pod_id)

    json(conn, %{
      name: pod.mentee.name,
      id: pod.id,
      timesheet_entries: Enum.map(pod.timesheet_entries, fn tse ->
        %{category: Tzn.Util.humanize(tse.category), started_at: tse.started_at, ended_at: tse.ended_at, notes: tse.notes}
      end) |> Enum.sort_by(& &1.started_at, {:desc, NaiveDateTime}),
      hours_mentored: pod.hour_counts.hours_used |> Number.Conversion.to_float() |> Float.round(2),
      mentor_name: if pod.mentor do
        pod.mentor.name
      else
        nil
      end,
      grade: pod.mentee.grade,
    notes: pod.internal_note
    })
  end

  def load_profiles(conn, _) do
    cu = conn.assigns.current_user |> Tzn.Repo.preload([
      :school_admin_profile,
      :mentee_profile,
      :mentor_profile,
      :admin_profile,
      :parent_profile
    ])

    assign(conn, :current_user, cu)
  end

  def load_base_data(conn, _) do
    d = Tzn.PodGroups.list_groups(conn.assigns.current_user.school_admin_profile)
    |> Repo.preload([
      :school_admins,
      pods: [
        :timesheet_entries,
        :mentor,
        :hour_counts,
        mentee: [:parents],
        timeline: [:calendar_event_markings, calendars: [:events]]
      ]
    ])

    assign(conn, :data, d)
  end

  def my_pods(conn) do
    Enum.flat_map(conn.assigns.data, fn pod_group -> pod_group.pods end)
  end

end
