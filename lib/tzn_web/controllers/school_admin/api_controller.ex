defmodule TznWeb.SchoolAdmin.ApiController do
  use TznWeb, :controller

  plug :load_profiles
  plug :load_base_data
  plug Accent.Plug.Response, json_codec: Jason, default_case: Accent.Case.Camel

  alias Tzn.Repo
  alias Tzn.DB.{PodGroup, Pod, SchoolAdmin}

  def handle(conn, %{"query" => "cohorts"}) do
    json(
      conn,
      Enum.map(conn.assigns.data, fn pod_group -> serialize(pod_group) end)
    )
  end

  def handle(conn, %{"query" => "cohort", "id" => cohort_id}) do
    json(conn, Tzn.Util.find_by_id(conn.assigns.data, cohort_id) |> serialize())
  end

  def handle(conn, %{"query" => "student", "id" => pod_id}) do
    pod = my_pods(conn) |> Tzn.Util.find_by_id(pod_id)
    json(conn, serialize(pod))
  end

  def handle(conn, %{"query" => "cohort_highlights", "id" => cohort_id}) do
    pod_group = conn.assigns.data |> Tzn.Util.find_by_id(cohort_id)
    pods = pod_group.pods

    highlights =
      pods
      |> Enum.map(fn pod ->
        h = Tzn.PodGroupReporting.student_highlights(pod)

        description =
          cond do
            h.consecutive_missed_sessions > 1 ->
              "#{pod.mentee.name} missed their last #{h.consecutive_missed_sessions} sessions"

            Tzn.Util.within_n_days_ago(h.last_milestone_completion, 30) ->
              "#{pod.mentee.name} completed their #{Number.Human.number_to_ordinal(h.milestones_completed)} milestone"

            # h.hours_mentored_hit_10_at ->
            #   "#{pod.mentee.name} has received over 10 hours of 1:1 mentorship!"

            # h.hours_mentored_hit_5_at ->
            #   "#{pod.mentee.name} has received over 5 hours of 1:1 mentorship!"

            h.missed_sessions_last_30_days > 0 ->
              "#{pod.mentee.name} missed #{Tzn.Util.pluralize(h.missed_sessions_last_30_days, "session")} in the last month"

            Tzn.Util.within_n_days_ago(h.onboarded_at, 30) ->
              "#{pod.mentee.name} recently completed their onboarding form"

            true ->
              nil
          end

        %{
          description: description,
          student_id: pod.id
        }
      end)
      |> Enum.reject(&is_nil(&1.description))
      |> Enum.shuffle()
      |> Enum.take(3)

    conn |> json(highlights)
  end

  def handle(conn, %{"query" => "my_name"}) do
    data = %{
      my_name: conn.assigns.current_user.school_admin_profile.name
    }

    json(conn, data)
  end

  defp move_milestones_to_end_of_list(events) do
    # Move milestones to bottom of list
    milestones = Enum.filter(events, fn event ->
      case event do
        %{todo: %{is_milestone: true}} -> true
        _ -> false
      end
    end)

    events = Enum.filter(events, fn event ->
      case event do
        %{todo: %{is_milestone: true}} -> false
        _ -> true
      end
    end)

    events ++ milestones
  end

  def handle(conn, %{"query" => "timeline", "student_id" => pod_id} = params) do
    pod = my_pods(conn) |> Tzn.Util.find_by_id(pod_id)
    pod_timeline = Tzn.Timelines.get_or_create_timeline(pod)
    events = Tzn.Timelines.aggregate_calendar_events(pod_timeline)
    sort = Map.get(params, "sort", "asc")
    include_past = Map.get(params, "include_past", "n")

    events =
      if include_past == "y" do
        events
      else
        Enum.reject(events, fn e ->
          Timex.before?(e.date, Timex.now())
        end)
      end

    events =
      if sort == "asc" do
        Enum.sort_by(events, fn e -> e.date end, {:asc, Date})
      else
        Enum.sort_by(events, fn e -> e.date end, {:desc, Date})
      end

    events =
      Enum.map(events, fn event ->
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
              title: "To-Do",
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

  # General timeline for a cohort
  def handle(conn, %{"query" => "timeline", "cohort_id" => pod_group_id} = params) do
    sort = Map.get(params, "sort", "asc")
    include_past = Map.get(params, "include_past", "n")
    limit = Map.get(params, "limit", 0)

    limit =
      if is_binary(limit) do
        String.to_integer(limit)
      else
        limit
      end

    events = Tzn.Timelines.general_calendar_events()

    events =
      if include_past == "y" do
        events
      else
        Enum.reject(events, fn e ->
          Timex.before?(e.date, Timex.now())
        end)
      end

    events =
      if sort == "asc" do
        Enum.sort_by(events, fn e -> e.date end, {:asc, Date})
      else
        Enum.sort_by(events, fn e -> e.date end, {:desc, Date})
      end

    events =
      if limit && limit > 0 do
        Enum.take(events, limit)
      else
        events
      end

    events =
      Enum.map(events, fn event ->
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

  def handle(conn, %{"query" => "student_highlights", "student_id" => pod_id}) do
    pod_id =
      if is_binary(pod_id) do
        String.to_integer(pod_id)
      else
        pod_id
      end

    pod = Enum.find(my_pods(conn), fn p -> p.id == pod_id end)
    h = Tzn.PodGroupReporting.student_highlights(pod)

    description =
      cond do
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

        true ->
          nil
      end

    json(conn, %{highlight: description})
  end

  def load_profiles(conn, _) do
    cu =
      conn.assigns.current_user
      |> Tzn.Repo.preload([
        :school_admin_profile,
        :mentee_profile,
        :mentor_profile,
        :admin_profile,
        :parent_profile
      ])

    assign(conn, :current_user, cu)
  end

  def load_base_data(conn, _) do
    {_, d} =
      Cachex.fetch(
        :school_admin_cache,
        conn.assigns.current_user.school_admin_profile.id,
        fn _key ->
          Tzn.PodGroups.list_groups(conn.assigns.current_user.school_admin_profile)
          |> Repo.preload([
            :school_admins,
            pods: [
              :timesheet_entries,
              :mentor,
              :hour_counts,
              :flags,
              :todos,
              mentee: [:parents],
              timeline: [:calendar_event_markings, calendars: [:events]]
            ]
          ])
        end
      )
    # TODO: Cachex.fetch didn't support setting expiration before
    # but now it does so combine the .fetch and .expire calls
    Cachex.expire(
      :school_admin_cache,
      conn.assigns.current_user.school_admin_profile.id,
      :timer.seconds(60)
    )

    assign(conn, :data, d)
  end

  def my_pods(conn) do
    Enum.flat_map(conn.assigns.data, fn pod_group -> pod_group.pods end)
  end

  def serialize(%PodGroup{} = cohort) do
    %{
      id: cohort.id,
      name: cohort.name,
      school_admins: Enum.map(cohort.school_admins, fn sa -> serialize(sa) end),
      students: Enum.map(cohort.pods, fn pod -> serialize(pod) end)
      # TODO: Milestones for the cohort
    }
  end

  def serialize(%SchoolAdmin{} = sa) do
    %{
      name: sa.name
    }
  end

  def serialize(%Pod{} = pod) do
    %{
      name: pod.mentee.name,
      id: pod.id,
      timesheet_entries:
        Enum.map(pod.timesheet_entries, fn tse ->
          %{
            id: tse.id,
            category: Tzn.Util.humanize(tse.category),
            started_at: tse.started_at,
            ended_at: tse.ended_at,
            notes: tse.notes
          }
        end)
        |> Enum.sort_by(& &1.started_at, {:desc, NaiveDateTime}),
      hours_mentored:
        pod.hour_counts.hours_used |> Number.Conversion.to_float() |> Float.round(2),
      mentor_name:
        if pod.mentor do
          pod.mentor.name
        else
          nil
        end,
      grade: pod.mentee.grade,
      notes: pod.internal_note,
      flags:
        pod.flags
        |> Tzn.Pods.sort_flags()
        |> Enum.filter(& &1.school_admin_can_read)
        |> Enum.map(fn flag ->
          %{
            id: flag.id,
            status: flag.status,
            description: flag.description,
            created_at: flag.inserted_at,
            updated_at: flag.updated_at
          }
        end),
      total_milestones: Enum.count(pod.todos, fn t -> t.is_milestone end),
      completed_milestones: Enum.count(pod.todos, fn t -> t.is_milestone && t.completed end),
      milestones: pod.todos |> Enum.filter(& &1.is_milestone) |> Enum.map(fn milestone ->
        %{
          id: milestone.id,
          is_priority: milestone.is_priority,
          text: milestone.todo_text,
          is_completed: milestone.completed
        }
      end),
      any_open_flags: Tzn.Pods.open_flags?(pod, :school_admin),
      current_priority:
        Enum.find_value(pod.todos, nil, fn t ->
          if t.is_priority do
            t.todo_text
          else
            nil
          end
        end)
    }
  end
end
