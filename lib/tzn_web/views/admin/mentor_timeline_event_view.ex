defmodule TznWeb.Admin.MentorTimelineEventView do
  use TznWeb, :view

  def format_date(date) do
    case Timex.format(date, "%B %d %Y", :strftime) do
      {:ok, formatted} -> formatted
      {:error, _} -> date
      _ -> "N/A"
    end
  end
end
