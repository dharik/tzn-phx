defmodule Tzn.Scripts.MigratePodTodos do
  import Ecto.Query
  alias Tzn.Repo
  alias Tzn.DB.Pod

  def run do
    from(p in Pod, where: p.active == true)
    |> Repo.all()
    |> Repo.preload(:todos)
    |> Enum.reject(fn pod ->
      # Pod already has todos so don't try to migrate
      Enum.any?(pod.todos)
    end)
    |> Enum.each(fn pod ->
      Enum.each(extract_notes(pod.mentor_todo_notes), fn item ->
        {:ok, _} = Tzn.Pods.create_todo(%{
          pod_id: pod.id,
          todo_text: item,
          assignee_type: "mentor",
          due_date: Timex.now() |> Timex.shift(months: 1) |> Timex.to_date()
        })
      end)

      Enum.each(extract_notes(pod.mentee_todo_notes), fn item ->
        {:ok, _} = Tzn.Pods.create_todo(%{
          pod_id: pod.id,
          todo_text: item,
          assignee_type: "mentee",
          due_date: Timex.now() |> Timex.shift(months: 1) |> Timex.to_date()
        })
      end)

      Enum.each(extract_notes(pod.parent_todo_notes), fn item ->
        {:ok, _} = Tzn.Pods.create_todo(%{
          pod_id: pod.id,
          todo_text: item,
          assignee_type: "parent",
          due_date: Timex.now() |> Timex.shift(months: 1) |> Timex.to_date()
        })
      end)
    end)
  end

  def extract_notes(notes) when is_nil(notes) do
    []
  end

  @doc """
  Pluck out todos from `notes`
  """
  def extract_notes(notes) when is_binary(notes) do
    {:ok, document} = Floki.parse_document(notes)

    matches =
      document
      |> Floki.find("li")
      |> Enum.map(&Floki.text/1)
      |> Enum.reject(fn item ->
        String.length(item) < 5
      end)

    if Enum.empty?(matches) do
      document
      |> Floki.find("p")
      |> Enum.map(&Floki.text/1)
      |> Enum.reject(fn item -> String.length(item) < 5 end)
    else
      matches
    end
  end
end
