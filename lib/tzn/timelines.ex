defmodule Tzn.Timelines do
  alias Tzn.Repo
  import Ecto.Query
  alias Tzn.DB.{Calendar, CalendarEvent, Timeline}

  def list_calendars(:admin) do
    Repo.all(Calendar) |> Repo.preload(:events) |> Enum.sort_by(& {&1. type, &1.name})
  end

  def list_calendars(:public) do
    Repo.all(Calendar)
    |> Repo.preload(:events)
    |> Enum.filter(& &1.searchable)
    |> Enum.sort_by(& &1.name)
  end

  def get_calendar(id) do
    Repo.get(Calendar, id) |> Repo.preload(:events)
  end

  def get_calendar_by_name(name) do
    Repo.get_by(Calendar, name: name) |> Repo.preload(:events)
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

  def aggregate_calendar_events(calendars, grad_year) do
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
  end

  def calculate_event_year(event, grad_year) do
    if event.month >= 9 do
      # After september means it's fall so push it back an extra year
      grad_year - grade_to_offset(event.grade) - 1
    else
      grad_year - grade_to_offset(event.grade)
    end
  end

  def grade_to_offset(grade) do
    case grade do
      "freshman" -> 3
      :freshman -> 3
      "sophomore" -> 2
      :sophomore -> 2
      "junior" -> 1
      :junior -> 1
      "senior" -> 0
      :senior -> 0
    end
  end

  def get_timeline(access_key) do
    t =
      Repo.get_by(Timeline, access_key: access_key) ||
        Repo.get_by(Timeline, readonly_access_key: access_key)

    if t do
      t |> Repo.preload(calendars: [:events])
    else
      nil
    end
  end


  def create_timeline() do
    %Timeline{}
    |> Timeline.changeset(%{
      access_key: Ecto.UUID.generate(),
      readonly_access_key: Ecto.UUID.generate(),
      graduation_year:  Timex.now().year + 2
    })
    |> Ecto.Changeset.put_assoc(:calendars,  Enum.filter(list_calendars(:public), & &1.subscribed_by_default))
    |> Repo.insert()
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
end
