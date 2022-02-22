defmodule Tzn.Jobs.BiweeklyUpdateEmails do
  import Ecto.Query, warn: false
  alias Tzn.Transizion.Mentee
  alias Tzn.Repo

  def run do
    # Parent updates
    Repo.all(
      from(
        m in Mentee,
        where: m.archived == false,
        where: not (m.grade == "college")
      )
    )
    |> Repo.preload(:hour_counts)
    |> Enum.filter(fn m ->
      # Ensure mentee has at least 3 hours left in contract
      Number.Conversion.to_float(m.hour_counts.hours_purchased) -
        Number.Conversion.to_float(m.hour_counts.hours_used) > 3.0
    end)
    |> Enum.each(fn m ->
      Task.start(fn ->
        Process.sleep(Enum.random(1..60) * 1000)
        Tzn.Emails.ParentTodos.maybe_send_for_mentee(m)
      end)
    end)
  end
end
