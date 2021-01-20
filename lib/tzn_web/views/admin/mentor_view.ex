defmodule TznWeb.Admin.MentorView do
  use TznWeb, :view

  def format_date(date) do
    case Timex.format(date, "%b %d %l:%M %p", :strftime) do
      {:ok, formatted} -> formatted
      {:error, _} -> date
      _ -> "N/A"
    end
  end

  def sorted_by_hours_this_month(mentors) do
    Enum.sort_by(mentors, fn mentor ->
      most_recent_month_data = most_recent_month(mentor.monthly_hour_counts)

      if most_recent_month_data && 
        most_recent_month_data.year == Date.utc_today.year && 
        most_recent_month_data.month == Date.utc_today.month do
        most_recent_month_data.hours |> Decimal.to_float
      else
        0.0
      end
    end, :desc)
  end

  def most_recent_month(counts_by_month) do
    counts_by_month |> Enum.max_by(fn count -> count.year * 1000 + count.month end, fn -> nil end)
  end
end
