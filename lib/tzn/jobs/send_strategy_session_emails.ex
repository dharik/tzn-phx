defmodule Tzn.Jobs.SendStrategySessionEmails do
  import Ecto.Query

  alias Tzn.Transizion.StrategySession
  alias Tzn.Repo

  def run do
    sessions =
      Repo.all(
        from s in StrategySession,
          where: s.emailed == false and s.published == true
      )
      |> Repo.preload(:mentee)

    Enum.map(sessions, fn s ->
      IO.puts(s.email_subject)
      IO.puts(s.mentee.parent1_email)
      IO.puts(s.mentee.parent2_email)
      IO.puts """

      Dear #{s.mentee.parent1_name},
      Your child did a thing #{s.notes}

      - The tzn team
      """
      StrategySession.email_sent_changeset(s)
      |> Repo.update
    end)
  end
end
