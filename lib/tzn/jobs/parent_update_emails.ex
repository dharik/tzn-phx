defmodule Tzn.Jobs.ParentUpdateEmails do
  import Ecto.Query, warn: false
  alias Tzn.Repo
  alias Tzn.Transizion.Mentee
  require Logger

  # This should only run at most every 2 weeks
  def biweekly_minimum do
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
        Logger.info("Maybe sending parent update for mentee #{m.id}")
        Tzn.Emails.ParentTodos.maybe_send_for_mentee(m)
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
      from(mc in Tzn.Transizion.MenteeChanges,
          where: mc.field in ["parent_todo_notes", "mentee_todo_notes", "mentor_todo_notes"],
          where: mc.updated_at > ^updated_after,
          where: mc.updated_at < ^updated_before,
          distinct: mc.mentee_id,
          select: mc.mentee_id
        )
    )
    |> Enum.map(fn mentee_id ->
      Tzn.Mentee.get_mentee(mentee_id) |> Repo.preload(:hour_counts)
    end)
    |> Enum.reject(fn m -> m.archived end)
    |> Enum.reject(fn m -> m.grade == "college" end)
    |> Enum.filter(fn m ->
      # Ensure mentee has at least 3 hours left in contract
      Number.Conversion.to_float(m.hour_counts.hours_purchased) -
        Number.Conversion.to_float(m.hour_counts.hours_used) > 3.0
    end)
    |> Enum.each(fn m ->
      Task.start(fn ->
        Process.sleep(Enum.random(1..60) * 1000)
        Logger.info("Maybe sending parent update for mentee #{m.id}")
        Tzn.Emails.ParentTodos.maybe_send_for_mentee(m)
      end)
    end)
  end
end
