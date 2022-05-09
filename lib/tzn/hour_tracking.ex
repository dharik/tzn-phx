defmodule Tzn.HourTracking do
  alias Tzn.DB.Pod

  def low_hours?(nil) do
    false
  end

  def low_hours?(%Pod{} = p) do
    hours_remaining(p) < 5.0
  end

  def hours_remaining(%Pod{} = p) do
    Number.Conversion.to_float(p.hour_counts.hours_remaining)
  end

  def hours_by_grade(%Pod{timesheet_entries: timesheet_entries}) do
    timesheet_entries
    |> Enum.group_by(& &1.mentee_grade)
    |> Map.to_list()
    |> Enum.map(fn {grade, entries_for_grade} ->
      total_hours = entries_for_grade
      |> Enum.map(fn e -> Tzn.Util.diff_in_hours(e.ended_at, e.started_at) |> Decimal.to_float() end)
      |> Enum.sum()

      {grade, total_hours}
    end)
  end
end
