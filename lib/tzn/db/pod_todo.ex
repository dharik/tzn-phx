defmodule Tzn.DB.PodTodo do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pod_todos" do
    belongs_to :pod, Tzn.DB.Pod

    field :todo_text, :string

    field :completed, :boolean, default: false
    field :completed_changed_at, :naive_datetime

    # mentor, mentee, parent
    field :completed_changed_by, :string

    # mentor, mentee, parent
    field :assignee_type, :string

    field :due_date, :date

    field :deleted_at, :naive_datetime

    field :is_milestone, :boolean
    field :is_priority, :boolean

    timestamps()
  end

  def changeset(%__MODULE__{} = pod_todo, attrs \\ %{}) do
    pod_todo
    |> cast(attrs, [
      :todo_text,
      :completed,
      :completed_changed_at,
      :completed_changed_by,
      :assignee_type,
      :due_date,
      :deleted_at,
      :pod_id,
      :is_milestone,
      :is_priority
    ])
    |> validate_required(:todo_text)
    |> validate_required(:due_date)
    |> validate_length(:todo_text, min: 5)
    |> foreign_key_constraint(:pod_id)
    |> validate_inclusion(:assignee_type, ["mentee", "mentor", "parent"])
  end

  def completed_changeset(%__MODULE__{} = pod_todo, attrs \\ %{}) do
    pod_todo
    |> cast(attrs, [
      :completed,
      :completed_changed_at,
      :completed_changed_by
    ])
    |> validate_inclusion(:completed_changed_by, ["mentee", "mentor", "parent"])
    |> set_completed_changed_at()
  end

  def set_completed_changed_at(changeset) do
    case fetch_change(changeset, :completed) do
      {:ok, _} ->
        put_change(changeset, :completed_changed_at, NaiveDateTime.local_now())

      :error ->
        changeset
    end
  end
end
