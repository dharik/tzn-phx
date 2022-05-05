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
end
