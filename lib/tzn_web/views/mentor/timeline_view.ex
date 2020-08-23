defmodule TznWeb.Mentor.TimelineView do
  use TznWeb, :view

  def upcoming_events(events) do
    Enum.filter(events, fn event ->
      days_from_now(event.date) > 0 && days_from_now(event.date) < 360
    end)
  end

  def past_events(events) do
    Enum.filter(events, fn event -> days_from_now(event.date) < 0 end)
  end

  def days_from_now(date) do
    NaiveDateTime.diff(date, NaiveDateTime.local_now(), :second) / 3600 / 24
  end

  def grouped_by_year_month(events) do
    events
    |> Enum.group_by(fn e -> date_to_year_month_str(e.date) end)
  end

  def date_to_year_month_str(date) do
    case Timex.format(date, "%B %Y", :strftime) do
      {:ok, formatted} -> formatted
      {:error, _} -> "N/A"
      _ -> "N/A"
    end
  end

  def format_date(date) do
    case Timex.format(date, "%b %d", :strftime) do
      {:ok, formatted} -> formatted
      {:error, _} -> date
      _ -> "N/A"
    end
  end

  def is_complete?(event, event_markings) do
    false
    # case event_markings |> Map.get(event.id) do
    #   nil -> false
    #   marking -> marking.completed
    # end
  end

  def get_marking(event, event_markings) do
    event_markings |> Map.get(event.id)
  end
  
  def marking_changeset do

  end
end
