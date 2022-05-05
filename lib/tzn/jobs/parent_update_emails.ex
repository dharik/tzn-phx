defmodule Tzn.Jobs.ParentUpdateEmails do
  import Ecto.Query, warn: false
  alias Tzn.Repo
  alias Tzn.DB.{Pod, PodChanges}
  require Logger

  # This should only run at most every 2 weeks
  def biweekly_minimum do
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

  @doc """
  Look for mentees whose todo lists were updated recently and
  # maybe send out parent emails
  """
  def todo_list_changed do
    # Only look for changes in the last day or two to keep the script small
    updated_after = Timex.now() |> Timex.shift(days: -2)

    # Ensure it's been at least a few hours since the update in case
    # the mentor is still writing the update
    updated_before = Timex.now() |> Timex.shift(hours: -3)

    Repo.all(
      from(pc in PodChanges,
        where: pc.field in ["parent_todo_notes", "mentee_todo_notes", "mentor_todo_notes"],
        where: pc.updated_at > ^updated_after,
        where: pc.updated_at < ^updated_before,
        distinct: pc.pod_id,
        select: pc.pod_id
      )
    )
    |> Enum.map(fn pod_id ->
      Tzn.Pods.get_pod(pod_id)
    end)
    |> Enum.filter(fn p -> p.active end)
    |> Enum.reject(fn p -> p.mentee.grade == "college" end)
    |> Enum.filter(fn p ->
      Number.Conversion.to_float(p.hour_counts.hours_remaining) > 3.0
    end)
    |> Enum.each(fn p ->
      Task.start(fn ->
        Process.sleep(Enum.random(1..60) * 1000)
        Logger.info("Maybe sending parent update for mentee #{p.mentee.id} (pod: #{p.id})")
        Tzn.Emails.ParentTodos.maybe_send_for_pod(p)
      end)
    end)
  end
end
