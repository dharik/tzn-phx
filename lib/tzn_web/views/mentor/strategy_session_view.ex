defmodule TznWeb.Mentor.StrategySessionView do
  use TznWeb, :view

  def low_hours_warning?(hour_counts) do
    hours_left(hour_counts) < 2
  end

  def hours_left(hour_counts) do
    (hour_counts.hours_purchased |> Decimal.to_float) - (hour_counts.hours_used |> Decimal.to_float)
  end
end
