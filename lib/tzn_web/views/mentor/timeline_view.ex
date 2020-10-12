defmodule TznWeb.Mentor.TimelineView do
  use TznWeb, :view

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

  def has_status(event, status) do
    if event.marking do
      event.marking.status == status
    else
      status == "incomplete"
    end
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
