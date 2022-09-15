defmodule Tzn.Timelines do
  alias Tzn.Repo
  alias Tzn.DB.{Calendar, CalendarEvent, Timeline, Pod, CalendarEventMarking}
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
      t |> Repo.preload([:pod, :calendar_event_markings, calendars: [:events]])
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

  def mark_calendar_event(%CalendarEvent{} = event, %Timeline{} = timeline, %{hidden: hidden}) do
    find_or_create_calendar_event_marking(event, timeline)
    |> update_marking(%{
      hidden_at:
        if hidden do
          Timex.now()
        else
          nil
        end
    })
  end

  def mark_calendar_event(%CalendarEvent{} = event, %Timeline{} = timeline, %{
        completed: completed
      }) do
    find_or_create_calendar_event_marking(event, timeline)
    |> update_marking(%{
      completed_at:
        if completed do
          Timex.now()
        else
          nil
        end
    })
  end

  def find_or_create_calendar_event_marking(%CalendarEvent{} = event, %Timeline{} = timeline) do
    Repo.get_by(Tzn.DB.CalendarEventMarking, calendar_event_id: event.id, timeline_id: timeline.id) ||
      Repo.insert!(%CalendarEventMarking{calendar_event_id: event.id, timeline_id: timeline.id})
  end

  def update_marking(%CalendarEventMarking{} = m, attrs \\ %{}) do
    CalendarEventMarking.changeset(m, attrs) |> Repo.update()
  end

  @type aggregated_event ::
          %{
            calendar: %Calendar{},
            calendar_event: %CalendarEvent{},
            date: Date.t(),
            hidden: boolean(),
            completed: boolean()
          }
          | %{todo: %Tzn.DB.PodTodo{}, date: Date.t(), hidden: boolean(), completed: boolean()}
          | %{
              mentor_timeline_event_marking: %Tzn.Transizion.MentorTimelineEventMarking{},
              mentor_timeline_event: %Tzn.Transizion.MentorTimelineEvent{},
              date: Date.t(),
              hidden: boolean(),
              completed: boolean()
            }

  @spec aggregate_calendar_events(%Timeline{}) :: [aggregated_event]
  def aggregate_calendar_events(%Timeline{} = timeline) do
    timeline = get_timeline(timeline.access_key)

    pod =
      if timeline.pod do
        # Make sure we load
        Tzn.Pods.get_pod!(timeline.pod.id)
      else
        nil
      end

    calendar_events =
      timeline.calendars
      |> Enum.flat_map(fn c ->
        Enum.map(c.events, fn e -> {c, e} end)
      end)
      |> Enum.map(fn {c, e} ->
        marking =
          Enum.find(timeline.calendar_event_markings, fn m -> m.calendar_event_id == e.id end)

        %{
          calendar: c,
          calendar_event: e,
          completed:
            if marking && marking.completed_at do
              true
            else
              false
            end,
          hidden:
            if marking && marking.hidden_at do
              true
            else
              false
            end,
          date: Date.new!(event_year(timeline.graduation_year, e.grade, e.month), e.month, e.day)
        }
      end)

    pod_todos =
      if pod do
        pod.todos
        |> Enum.reject(& &1.deleted_at)
        |> Enum.map(fn t ->
          %{
            todo: t,
            completed: t.completed,
            hidden:
              if t.deleted_at do
                true
              else
                false
              end,
            date: Date.new!(t.due_date.year, t.due_date.month, t.due_date.day)
          }
        end)
      else
        []
      end

    mentor_timeline_event_markings =
      if pod do
        Tzn.Transizion.mentor_timeline_event_markings(pod.mentee)
        |> Enum.map(fn m ->
          %{
            mentor_timeline_event_marking: m,
            mentor_timeline_event: m.mentor_timeline_event,
            completed: m.status == "completed",
            hidden: m.status == "not_applicable",
            date:
              Date.new!(
                event_year(
                  timeline.graduation_year,
                  m.mentor_timeline_event.grade,
                  m.mentor_timeline_event.date.month
                ),
                m.mentor_timeline_event.date.month,
                m.mentor_timeline_event.date.day
              )
          }
        end)
      else
        []
      end

    calendar_events ++ pod_todos ++ mentor_timeline_event_markings
  end

  @spec to_ical([aggregated_event], charlist()) :: charlist()
  def to_ical(events, calendar_name) do
    events =
      events
      |> Enum.reject(& &1.hidden)
      |> Enum.map(fn
        %{calendar: calendar, calendar_event: calendar_event, date: date} ->
          %{
            summary:
              if calendar.type == "college_cyclic" do
                "#{calendar_event.name} (#{calendar.name})"
              else
                calendar_event.name
              end,
            description: HtmlSanitizeEx.strip_tags(calendar_event.description),
            date: date,
            uid: :crypto.hash(:sha, "calendar-event-#{calendar_event.id}") |> Base.encode32()
          }

        %{todo: todo, date: date} ->
          %{
            description: todo.todo_text,
            summary: "#{Phoenix.Naming.humanize(todo.assignee_type)} Todo",
            date: date,
            uid: "todo-#{todo.id}"
          }

        %{mentor_timeline_event: mentor_timeline_event, date: date} ->
          %{
            description: mentor_timeline_event.notes,
            summary: "Mentor Event",
            date: date,
            uid: "mentor-timeline-event-#{mentor_timeline_event.id}"
          }
      end)

    Calibex.new_root(
      vevent:
        Enum.map(events, fn e ->
          [
            description: HtmlSanitizeEx.strip_tags(e.description),
            summary: e.summary,
            dtstart: [
              VALUE: "DATE",
              value:
                e.date
                |> Timex.to_datetime()
                |> Timex.format!("{YYYY}{0M}{0D}")
            ],
            dtstamp: e.date |> Timex.to_datetime(),
            uid: :crypto.hash(:sha, e.uid) |> Base.encode32()
          ]
        end),
      prodid: "-//Transizion//OrganizeU",
      last_modified: Timex.now(),
      name: calendar_name,
      "X-WR-CALNAME": calendar_name,
      "REFRESH-INTERVAL": [VALUE: "DURATION", value: "PT24H"]
    )
    |> Calibex.encode()
  end
end
