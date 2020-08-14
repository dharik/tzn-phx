defmodule TznWeb.Mentor.TimelineView do
  use TznWeb, :view

  def upcoming_events(events) do
    Enum.filter(events, fn event ->
      days_from_now(event.date) > 0 && days_from_now(event.date) < 30
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

end
