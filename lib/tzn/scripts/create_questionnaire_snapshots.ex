defmodule Tzn.Scripts.CreateQuestionnaireSnapshots do
  import Ecto.Query
  alias Tzn.Repo

  def run do
    from(q in Tzn.Questionnaire.Questionnaire, where: q.state == "complete")
      |> Repo.all()
      |> Repo.preload(:snapshots)
      |> Enum.filter(fn q ->
        # Narrow down to those that do not have a snapshot with the current state
        !Enum.any?(q.snapshots, fn s ->
          s.state == q.state
        end)
      end)
      |> Enum.each(fn q ->
        {:ok, snapshot} = Tzn.Questionnaire.save_snapshot(q)
      end)
  end
end
