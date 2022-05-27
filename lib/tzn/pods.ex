defmodule Tzn.Pods do
  import Ecto.Query

  alias Tzn.Transizion.{Mentee, Mentor}
  alias Tzn.Repo
  alias Tzn.DB.Pod
  alias Tzn.DB.PodTodo
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
        :todos,
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
      :todos,
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
      :todos,
      :mentor,
      :mentee,
      questionnaires: [:question_set]
    ])
    |> with_strategy_sessions()
  end

  def with_changes(%Pod{} = pod) do
    pod |> Repo.preload(changes: :user)
  end

  def with_strategy_sessions(%Pod{} = pod) do
    pod |> Repo.preload(strategy_sessions: [:mentor])
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

  def create_todo(attrs) do
    PodTodo.changeset(%PodTodo{}, attrs) |> Repo.insert()
  end

  def get_todo(id) do
    Repo.get(PodTodo, id)
  end

  def change_todo(todo \\ %PodTodo{}, attrs \\ %{}) do
    PodTodo.changeset(todo, attrs)
  end

  def update_todo(todo, attrs) do
    change_todo(todo, attrs) |> Repo.update()
  end

  def update_todo_complete_state(todo \\ %PodTodo{}, attrs \\ %{}) do
    PodTodo.completed_changeset(todo, attrs) |> Repo.update()
  end

  @doc """
  Returns either {:ok, pod} or {:error, message}
  """
  def todos_state(pod) do
    pod
    |> check_empty_todos()
    |> check_past_due_todos()
    |> check_last_touched_todos()
    |> check_unedited_todos()
  end

  defp check_unedited_todos({:ok, pod}) do
    check_unedited_todos(pod)
  end

  defp check_unedited_todos({:error, _} = error) do
    error
  end

  defp check_unedited_todos(pod) do
    if pod.active &&
         !Tzn.HourTracking.low_hours?(pod) &&
         pod.todos
         |> Enum.reject(& &1.deleted_at)
         |> Enum.reject(& &1.completed)
         |> Enum.filter(&(&1.todo_text == "Change me"))
         |> Enum.any?() do
      {:error, "There is a todo item that needs to be edited"}
    else
      {:ok, pod}
    end
  end

  defp check_empty_todos({:ok, pod}) do
    check_empty_todos(pod)
  end

  defp check_empty_todos({:error, error}) do
    {:error, error}
  end

  defp check_empty_todos(pod) do
    if pod.active &&
         !Tzn.HourTracking.low_hours?(pod) &&
         pod.todos
         |> Enum.reject(& &1.deleted_at)
         |> Enum.reject(& &1.completed)
         |> Enum.empty?() do
      {:error, "Needs at least one todo item"}
    else
      {:ok, pod}
    end
  end

  defp check_past_due_todos({:ok, pod}) do
    check_past_due_todos(pod)
  end

  defp check_past_due_todos({:error, error}) do
    {:error, error}
  end

  defp check_past_due_todos(pod) do
    if pod.active &&
         !Tzn.HourTracking.low_hours?(pod) &&
         pod.todos
         |> Enum.reject(& &1.deleted_at)
         |> Enum.reject(& &1.completed)
         |> Enum.filter(& &1.due_date)
         |> Enum.any?(fn todo ->
           Timex.now() |> Timex.after?(todo.due_date)
         end) do
      {:error, "There is a todo past its due date that hasn't been marked complete"}
    else
      {:ok, pod}
    end
  end

  defp check_last_touched_todos({:ok, pod}) do
    check_last_touched_todos(pod)
  end

  defp check_last_touched_todos(r = {:error, _}) do
    r
  end

  defp check_last_touched_todos(pod) do
    if pod.active && !Tzn.HourTracking.low_hours?(pod) &&
         pod.todos
         |> Enum.filter(&(&1.assignee_type == "mentee" || &1.assignee_type == "mentor"))
         |> Enum.filter(fn todo ->
           Tzn.Util.within_n_days_ago(todo.updated_at, 30)
         end)
         |> Enum.empty?() do
      {:error, "Mentee or Mentor todo list needs to be updated"}
    else
      {:ok, pod}
    end
  end
end
