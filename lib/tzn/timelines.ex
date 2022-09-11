defmodule Tzn.Timelines do
  alias Tzn.Repo
  alias Tzn.DB.{Calendar, CalendarEvent, Timeline, Pod}
  import Tzn.GradeYearConversions

  def list_calendars(:admin) do
    Repo.all(Calendar) |> Repo.preload(:events) |> Enum.sort_by(&{&1.type, &1.name})
  end

  def list_calendars(:public) do
    Repo.all(Calendar)
    |> Repo.preload(:events)
    |> Enum.filter(&(&1.searchable || &1.subscribed_by_default))
    |> Enum.sort_by(& &1.name)
  end

  def get_calendar(id) do
    Repo.get(Calendar, id) |> Repo.preload(:events)
  end

  def get_calendar_by_name(name) do
    (Repo.get_by(Calendar, lookup_name: name) || Repo.get_by(Calendar, name: name))
    |> Repo.preload(:events)
  end

  def change_calendar(%Calendar{} = calendar, attrs \\ %{}) do
    Calendar.changeset(calendar, attrs)
  end

  def create_calendar(attrs) do
    %Calendar{}
    |> Calendar.changeset(attrs)
    |> Repo.insert()
  end

  def update_calendar(%Calendar{} = calendar, attrs) do
    calendar
    |> Calendar.changeset(attrs)
    |> Repo.update()
  end

  def delete_calendar(%Calendar{} = c) do
    if is_special_calendar(c) do
      raise "Cannot delete a special calendar because it's hardcoded in the backend"
    end

    Repo.delete(c)
  end

  def get_event(id) do
    Repo.get(CalendarEvent, id)
  end

  def change_event(%CalendarEvent{} = event, attrs \\ %{}) do
    CalendarEvent.changeset(event, attrs)
  end

  def create_event(attrs) do
    %CalendarEvent{}
    |> CalendarEvent.changeset(attrs)
    |> Repo.insert()
  end

  def update_event(%CalendarEvent{} = event, attrs) do
    event
    |> CalendarEvent.changeset(attrs)
    |> Repo.update()
  end

  def delete_event(%CalendarEvent{} = e) do
    Repo.delete(e)
  end

  def get_timeline(access_key) do
    t =
      Repo.get_by(Timeline, access_key: access_key) ||
        Repo.get_by(Timeline, readonly_access_key: access_key)

    if t do
      t |> Repo.preload([:pod, calendars: [:events]])
    else
      nil
    end
  end

  def is_special_calendar(%Calendar{} = c) do
    c.id == 1051 || c.id == 980
  end

  def logged_in_general_calendar do
    get_calendar(1051)
  end

  def set_calendars_for_timeline(calendars, timeline) do
    change_timeline(timeline, %{
      updated_at: Timex.now()
    })
    |> Ecto.Changeset.put_assoc(:calendars, calendars)
    |> Repo.update()
  end

  def update_timeline(t = %Timeline{}, attrs) do
    t
    |> Timeline.changeset(attrs)
    |> Repo.update()
  end

  def change_timeline(%Timeline{} = timeline, attrs \\ %{}) do
    Timeline.changeset(timeline, attrs)
  end

  def create_timeline() do
    %Timeline{}
    |> Timeline.changeset(%{
      access_key: Ecto.UUID.generate(),
      readonly_access_key: Ecto.UUID.generate(),
      graduation_year: Timex.now().year + 1
    })
    |> Ecto.Changeset.put_assoc(
      :calendars,
      Enum.filter(list_calendars(:public), & &1.subscribed_by_default)
    )
    |> Repo.insert()
  end

  def get_or_create_timeline(%Pod{timeline: timeline}) when is_map(timeline) do
    timeline
  end

  def get_or_create_timeline(%Pod{} = pod) do
    mentee = Ecto.assoc(pod, :mentee) |> Repo.one!()

    {:ok, t} =
      %Timeline{}
      |> Timeline.changeset(%{
        access_key: Ecto.UUID.generate(),
        readonly_access_key: Ecto.UUID.generate(),
        graduation_year: graduation_year(mentee.grade)
      })
      |> Ecto.Changeset.put_assoc(
        :calendars,
        [logged_in_general_calendar()]
      )
      |> Repo.insert()

    {:ok, _} = Tzn.Pods.change_pod(pod, %{timeline_id: t.id}) |> Repo.update()

    t
  end

  # events =
  #   Tzn.Timelines.aggregate_calendar_events(
  #     timeline.calendars,
  #     timeline.graduation_year
  #   )
  # event = %{title, description, Date, status, type}
  def to_ical(events) do
    # events
    # |> Enum.map(fn e ->
    #   calendar = Enum.find(timeline.calendars, nil, fn c -> e.calendar_id == c.id end)

    #   [
    #     description: HtmlSanitizeEx.strip_tags(e.description),
    #     summary:
    #       if calendar.type == "college_cyclic" do
    #         "#{e.name} (#{calendar.name})"
    #       else
    #         e.name
    #       end,
    #     dtstart: [
    #       VALUE: "DATE",
    #       value:
    #         Timex.Date.new!(e.year, e.month, e.day)
    #         |> Timex.to_datetime()
    #         |> Timex.format!("{YYYY}{0M}{0D}")
    #     ],
    #     dtstamp: Timex.Date.new!(e.year, e.month, e.day) |> Timex.to_datetime(),
    #     # Later on the hash might be cz-todo-{id}
    #     uid: :crypto.hash(:sha, "organizeu-event-#{e.id}") |> Base.encode32()
    #   ]
    # end)

    # root =
    #   Calibex.new_root(
    #     vevent: events,
    #     prodid: "-//Transizion//OrganizeU",
    #     last_modified: Timex.now(),
    #     name: "College Application Timeline from OrganizeU",
    #     "X-WR-CALNAME": "College Application Timeline from OrganizeU",
    #     "REFRESH-INTERVAL": [VALUE: "DURATION", value: "PT24H"]
    #   )

    # if ua = Plug.Conn.get_req_header(conn, "user-agent") do
    #   {:ok, _} =
    #     Tzn.Timelines.update_timeline(timeline, %{
    #       last_ical_sync_at: Timex.now(),
    #       last_ical_sync_client: to_string(ua)
    #     })
    # end
  end

  # For OU
  def aggregate_calendar_events(calendars, grad_year, include_past \\ true) do
    calendars
    |> Enum.flat_map(& &1.events)
    |> Enum.map(fn event ->
      Map.put(event, :year, calculate_event_year(event, grad_year))
    end)
    |> Enum.sort_by(
      fn event ->
        Date.new!(event.year, event.month, event.day)
      end,
      {:asc, Date}
    )
    |> Enum.filter(fn e ->
      if include_past do
        true
      else
        Timex.after?(Timex.Date.new!(e.year, e.month, e.day), Timex.now())
      end
    end)
  end

  # For mentors
  # pod -> %{
  #  calendar, calendar_event, date | todo, date | mentor_timeline_event, mentor_timeline_event_marking, date
  # }
  def aggregate_calendar_events(%Pod{} = pod) do
    grad_year = graduation_year(pod.mentee.grade)
    timeline = get_timeline(pod.timeline.access_key)

    calendar_events =
      timeline.calendars
      |> Enum.flat_map(fn c ->
        Enum.map(c.events, fn e -> {c, e} end)
      end)
      |> Enum.map(fn {c, e} ->
        %{
          calendar: c,
          calendar_event: e,
          date: Date.new!(event_year(grad_year, e.grade, e.month), e.month, e.day)
        }
      end)

    pod_todos =
      pod.todos
      |> Enum.reject(& &1.deleted_at)
      |> Enum.map(fn t ->
        %{
          todo: t,
          date: Date.new!(t.due_date.year, t.due_date.month, t.due_date.day)
        }
      end)

    mentor_timeline_event_markings =
      Tzn.Transizion.mentor_timeline_event_markings(pod.mentee)
      |> Enum.map(fn m ->
        %{
          mentor_timeline_event_marking: m,
          mentor_timeline_event: m.mentor_timeline_event,
          date:
            Date.new!(
              event_year(
                grad_year,
                m.mentor_timeline_event.grade,
                m.mentor_timeline_event.date.month
              ),
              m.mentor_timeline_event.date.month,
              m.mentor_timeline_event.date.day
            )
        }
      end)

    calendar_events ++ pod_todos ++ mentor_timeline_event_markings
  end
end
