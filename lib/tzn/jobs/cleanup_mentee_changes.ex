defmodule Tzn.Jobs.CleanupMenteeChanges do
  @moduledoc """
  The mentee_changes table gets written to without any throttling/debouncing.
  This module erases records written quickly one after another and only keeps the latest.

  1. Distinct mentee/field combinations in a previous hour
  2. For each combination, keep the latest. Delete the rest.
  """

  alias Tzn.Repo
  alias Tzn.Transizion.MenteeChanges
  import Ecto.Query

  def min_date do
    Timex.now() |> Timex.shift(hours: -2) |> Timex.to_naive_datetime()
  end

  def max_date do
    Timex.now() |> Timex.shift(hours: -1) |> Timex.to_naive_datetime()
  end

  def distinct_mentee_fields do
    from(m in MenteeChanges,
      where: m.updated_at > ^min_date() and m.updated_at < ^max_date(),
      select: [m.mentee_id, m.field],
      distinct: [m.mentee_id, m.field]
    )
    |> Repo.all()
  end

  def run do
    distinct_mentee_fields()
    |> Enum.each(fn [mentee_id, field] ->
      latest =
        from(c in MenteeChanges,
          where: c.updated_at > ^min_date() and c.updated_at < ^max_date(),
          where: c.mentee_id == ^mentee_id,
          where: c.field == ^field,
          order_by: [desc: :updated_at],
          limit: 1
        )
        |> Repo.one()

      if latest do
        from(c in MenteeChanges,
          where: c.updated_at > ^min_date() and c.updated_at < ^max_date(),
          where: c.mentee_id == ^mentee_id,
          where: c.field == ^field,
          where: c.id != ^latest.id
        )
        |> Repo.delete_all()
      end
    end)
  end
end
