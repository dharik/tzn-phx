defmodule Tzn.Scripts.PopulatePodsFromMentees do
  alias Tzn.Transizion.{Mentee, StrategySession, ContractPurchase, MenteeChanges}
  alias Tzn.Repo
  alias Tzn.DB.Pod
  require Logger

  def run do
    Repo.all(Mentee)
    |> Enum.each(fn m ->
      pod = Repo.get_by(Pod, mentee_id: m.id)

      unless pod do
        Pod.changeset(
          %Pod{mentee_id: m.id, mentor_id: m.mentor_id, active: !m.archived},
          Map.take(m, [
            :type,
            :internal_note,
            :mentor_rate,
            :mentor_todo_notes,
            :parent_todo_notes,
            :mentee_todo_notes,
            :college_list_access,
            :ecvo_list_access,
            :scholarship_list_access
          ])
        )
        |> Repo.insert()
      end
    end)

    Repo.all(Tzn.Transizion.TimesheetEntry)
    |> Enum.reject(& &1.pod_id)
    |> Enum.filter(& &1.mentee_id)
    |> Enum.each(fn tse ->
      # We know there is only one mentee profile per type
      pod = Repo.get_by(Pod, mentee_id: tse.mentee_id)

      Ecto.Changeset.change(tse, %{pod_id: pod.id}) |> Repo.update() # bypass the mentee_grade validation
    end)

    Repo.all(StrategySession)
    |> Enum.reject(& &1.pod_id)
    |> Enum.each(fn ss ->
      pod = Repo.get_by(Pod, mentee_id: ss.mentee_id)
      Tzn.Transizion.update_strategy_session(ss, %{pod_id: pod.id})
    end)

    Repo.all(ContractPurchase)
    |> Enum.reject(& &1.pod_id)
    |> Enum.each(fn cp ->
      pod = Repo.get_by(Pod, mentee_id: cp.mentee_id)
      Tzn.Transizion.update_contract_purchase(cp, %{pod_id: pod.id})
    end)

    Repo.all(MenteeChanges)
    |> Enum.each(fn mc ->
      pod = Repo.get_by(Pod, mentee_id: mc.mentee_id)
      Tzn.DB.PodChanges.changeset(%Tzn.DB.PodChanges{}, %{
        pod_id: pod.id,
        changed_by: mc.changed_by,
        field: mc.field,
        new_value: mc.new_value,
        old_value: nil,
        updated_at: mc.updated_at,
        inserted_at: mc.inserted_at
      }) |> Repo.insert()
    end)
  end
end
