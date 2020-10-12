defmodule TznWeb.Mentor.TimelineEventMarkingView do
  use TznWeb, :view

  def format_date(date) do
    case Timex.format(date, "%b %d", :strftime) do
      {:ok, formatted} -> formatted
      {:error, _} -> date
      _ -> "N/A"
    end
  end
end