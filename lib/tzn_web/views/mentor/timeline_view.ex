defmodule TznWeb.Mentor.TimelineView do
  use TznWeb, :view

  alias Tzn.Transizion.MentorTimelineEventMarking
  # Formats data more conveniently
  # events +
  # markings 
  # ---------
  # { 
  #   ...event,
  #   year_month_str, 
  #   marking: marking | nil, 
  #   status: "incomplete" | "in_progress" | "complete" 
  # }
  def view_data(events, markings) do
    events
    |> Enum.map(fn e -> Map.put(e, :year_month_str, date_to_year_month_str(e.date)) end)
    |> Enum.map(fn e -> Map.put(e, :marking, markings |> Map.get(e.id)) end)
    |> Enum.chunk_by(fn e -> e.year_month_str end)
  end

  def has_status(%{ marking: %MentorTimelineEventMarking{ status: "complete" }}, "complete") do
    true
  end
  def has_status(%{ marking: nil}, "complete") do
    false
  end

  def has_status(%{ marking: %MentorTimelineEventMarking{ status: "in_progress" }}, "in_progress") do
    true
  end
  def has_status(%{ marking: nil}, "in_progress") do
    false
  end

  def has_status(%{ marking: %MentorTimelineEventMarking{ status: "not_applicable" }}, "not_applicable") do
    true
  end
  def has_status(%{ marking: nil}, "not_applicable") do
    false
  end

  def has_status(%{ marking: %MentorTimelineEventMarking{ status: "incomplete" }}, "incomplete") do
    true
  end
  def has_status(%{ marking: %MentorTimelineEventMarking{ status: nil }}, "incomplete") do
    true
  end
  def has_status(%{ marking: nil}, "incomplete") do
    true
  end
  def has_status(event, status) do
    false
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
end
