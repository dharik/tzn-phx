defmodule Tzn.Pods do
  import Ecto.Query

  alias Tzn.Transizion.{Mentee, Mentor}
  alias Tzn.Repo
  alias Tzn.DB.Pod
  alias Tzn.DB.PodChanges
  alias Tzn.Users.User

  def list_pods(nil) do
    []
  end

  def list_pods(:admin) do
    Repo.all(Pod) |> Repo.preload([:hour_counts, :mentor, :mentee])
  end

  def list_pods(%Mentee{} = m) do
    if Ecto.assoc_loaded?(m.pods) do
      m.pods
    else
      Ecto.assoc(m, :pods)
      |> Repo.all()
      |> Repo.preload([
        :timesheet_entries,
        :contract_purchases,
        :hour_counts,
        :mentor,
        :mentee,
        questionnaires: [:question_set]
      ])
    end
  end

  def list_pods(%Mentor{} = m) do
    if Ecto.assoc_loaded?(m.pods) do
      m.pods
    else
      Ecto.assoc(m, :pods)
      |> Repo.all()
      |> Repo.preload([
        :hour_counts,
        :mentee
      ])
    end
  end

  def get_pod(nil) do
    nil
  end
  def get_pod("") do
    nil
  end

  def get_pod(id) do
    Repo.get(Pod, id)
    |> Repo.preload([
      :timesheet_entries,
      :contract_purchases,
      :hour_counts,
      :mentor,
      :mentee,
      questionnaires: [:question_set]
    ])
    |> with_strategy_sessions()
  end

  def get_pod!(id) do
    Repo.get!(Pod, id)
    |> Repo.preload([
      :timesheet_entries,
      :contract_purchases,
      :hour_counts,
      :mentor,
      :mentee,
      questionnaires: [:question_set]
    ])
    |> with_strategy_sessions()
  end

  def with_changes(%Pod{} = pod) do
    pod |> Repo.preload([changes: :user])
  end

  def with_strategy_sessions(%Pod{} = pod) do
    pod |> Repo.preload([strategy_sessions: [:mentor]])
  end

  def change_pod(pod \\ %Pod{}, attrs \\ %{}) do
    Tzn.DB.Pod.changeset(pod, attrs)
  end

  def create_pod(attrs \\ %{}) do
    %Pod{}
    |> Tzn.DB.Pod.changeset(attrs)
    |> Repo.insert()
  end

  def update_pod(pod, attrs, %User{} = user) do
    pod_changeset = Tzn.DB.Pod.changeset(pod, attrs)

    if pod_changeset.valid? do
      update_and_track_pod_changes(pod, pod_changeset, user)
    else
      Ecto.Changeset.apply_action(pod_changeset, :update)
    end
  end

  def update_and_track_pod_changes(%Pod{} = pod, changeset, %User{} = user) do
    Repo.transaction(fn ->
      pod_result = changeset |> Repo.update!()

      Map.to_list(changeset.changes)
      |> Enum.each(fn {field, value} ->
        Repo.insert!(
          PodChanges.changeset(%PodChanges{}, %{
            pod_id: pod.id,
            changed_by: user.id,
            field: Atom.to_string(field),
            old_value: Map.get(changeset.data, field) |> String.Chars.to_string(),
            new_value: String.Chars.to_string(value)
          })
        )
      end)

      pod_result
    end)
  end

  def most_recent_todo_list_updated_at(nil) do
    nil
  end

  def most_recent_todo_list_updated_at(%Pod{} = pod) do
    Repo.one(
      from(pc in PodChanges,
        where: pc.field in ["parent_todo_notes", "mentee_todo_notes", "mentor_todo_notes"],
        where: pc.id == ^pod.id,
        select: max(pc.updated_at)
      )
    )
  end
end
