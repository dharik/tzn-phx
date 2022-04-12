defmodule Tzn.HourTracking do
  alias Tzn.Transizion.{Mentee}
  alias Tzn.Repo

  def low_hours?(nil) do
    false
  end

  def low_hours?(%Mentee{} = m) do
    hours_remaining(m) < 5.0
  end

  def hours_remaining(%Mentee{} = m) do
    h =
      if Ecto.assoc_loaded?(m.hour_counts) do
        m.hour_counts
      else
        Ecto.assoc(m, :hour_counts) |> Repo.one()
      end

    purchased = Number.Conversion.to_float(h.hours_purchased)
    used = Number.Conversion.to_float(h.hours_used)

    purchased - used
  end
end
