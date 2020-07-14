defmodule TznWeb.Mentor.TimesheetEntryView do
  use TznWeb, :view

  def total_hours(timesheet_entries) do
    Enum.map(timesheet_entries, fn e -> Decimal.to_float(e.hours) end)
    |> Enum.sum
  end
end
