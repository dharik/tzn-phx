defmodule Tzn.Pods do
  import Ecto.Query

  alias Tzn.Transizion.{Mentee, Mentor}
  alias Tzn.Repo
  alias Tzn.DB.Pod
  alias Tzn.DB.PodTodo
  alias Tzn.DB.PodFlag
  alias Tzn.DB.PodChanges
  alias Tzn.Users.User

  def list_pods(nil) do
    []
  end

  def list_pods(:admin) do
    Repo.all(Pod) |> Repo.preload([:hour_counts, :mentor, :mentee, :flags])
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
      :timeline,
      :flags,
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
      :timeline,
      :flags,
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

  def create_flag(%Ecto.Changeset{} = changeset) do
    changeset |> Repo.insert()
  end

  def create_flag(attrs) do
    PodFlag.changeset(%PodFlag{}, attrs) |> Repo.insert()
  end

  def get_flag(id) do
    Repo.get(PodFlag, id)
  end

  def change_flag(flag \\ %PodFlag{}, attrs \\ %{}) do
    PodFlag.changeset(flag, attrs)
  end

  def update_flag(flag, attrs) do
    change_flag(flag, attrs) |> Repo.update()
  end

  def list_important_flags() do
    two_weeks_ago = Timex.now() |> Timex.shift(days: -14)
    from(f in PodFlag, where: f.status != "resolved" or f.updated_at > ^two_weeks_ago, order_by: [desc: f.inserted_at]) |> Repo.all()
  end

  def open_flags?(%Pod{flags: flags}) when is_list(flags) do
    Enum.any?(flags, fn flag ->
      flag.status == "open"
    end)
  end

  def open_flags?(%Pod{}) do
    false
  end

  def sort_flags(flags) when is_list(flags) do
    Enum.sort_by(flags, fn flag ->
      {flag.status == "resolved", -Timex.to_unix(flag.inserted_at)}
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
    |> check_priority_todos()
  end

  defp check_priority_todos({:error, _} = error), do: error
  defp check_priority_todos({:ok, pod}), do: check_priority_todos(pod)
  defp check_priority_todos(pod) do
    if Enum.any?(pod.todos, & &1.is_milestone) && !Enum.any?(pod.todos, & &1.is_priority && &1.is_milestone) do
      {:error, "A milestone needs to be prioritized"}
    else
      {:ok, pod}
    end
  end

  defp check_unedited_todos({:ok, pod}), do: check_unedited_todos(pod)
  defp check_unedited_todos({:error, _} = error), do: error
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
           Timex.now() |> Timex.shift(days: -1) |> Timex.after?(todo.due_date)
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
