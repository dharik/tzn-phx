defmodule TznWeb.Mentor.TimelineView do
  use TznWeb, :view

  def chunked_by_year_month(events) do
    events
    |> Enum.chunk_by(fn e -> date_to_year_month_str(e.date) end)
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

  def is_complete_for_mentee(event_marking, %{id: mentee_id}) when is_nil(event_marking) do
    false
  end

  def is_complete_for_mentee(event_marking, %{id: mentee_id}) do
    event_marking.mentee_id == mentee_id
  end
end
