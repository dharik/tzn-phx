defmodule Tzn.Jobs.ParentUpdateEmails do
  import Ecto.Query, warn: false
  alias Tzn.Repo
  alias Tzn.DB.Pod
  require Logger

  def daily_checks do
    Repo.all(
      from(p in Pod,
        where: p.active == true,
        preload: :mentee
      )
    )
    |> Enum.filter(& &1.mentee)
    |> Enum.reject(& &1.mentee.archived)
    |> Enum.reject(&(&1.mentee.grade == "college"))
    |> Repo.preload(:hour_counts)
    |> Enum.filter(fn p ->
      Number.Conversion.to_float(p.hour_counts.hours_remaining) > 3.0
    end)
    |> Enum.each(fn p ->
      Task.start(fn ->
        Process.sleep(Enum.random(1..60) * 1000)
        Logger.info("Maybe sending parent update for mentee #{p.mentee.id} (pod #{p.id}).")
        Tzn.Emails.ParentTodos.maybe_send_for_pod(p)
      end)
    end)
  end
end
