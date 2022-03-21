defmodule TznWeb.Parent.WorklogView do
  use TznWeb, :view

  def format_date(date) do
    case Timex.format(date, "%B %d, %Y", :strftime) do
      {:ok, formatted} -> formatted
      {:error, _} -> "N/A"
    end
  end

  def chart_data(timesheet_entries) do
    timesheet_entries
    |> Enum.reduce(%{}, fn tse, acc ->
      hours = Tzn.Util.diff_in_hours(tse.ended_at, tse.started_at) |> Number.Conversion.to_float()
      category = Tzn.Timesheets.get_category_by_slug(tse.category).name

      Map.update(acc, category, hours, fn hours_for_category ->
        hours + hours_for_category
      end)
    end)
  end
end
