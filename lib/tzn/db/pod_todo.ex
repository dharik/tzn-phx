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

    field :deleted, :boolean, virtual: true
    field :deleted_at, :naive_datetime

    field :is_milestone, :boolean, default: false
    field :is_priority, :boolean, default: false

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
    |> priority_requires_milestone()
    |> milestone_not_deleted()
    |> validate_length(:todo_text, min: 5)
    |> foreign_key_constraint(:pod_id)
    |> validate_inclusion(:assignee_type, ["mentee", "mentor", "parent"])
  end

  def admin_changeset(%__MODULE__{} = pod_todo, attrs \\ %{}) do
    pod_todo
    |> cast(attrs, [
      :todo_text,
      :completed,
      :assignee_type,
      :due_date,
      :deleted,
      :pod_id,
      :is_milestone,
      :is_priority
    ])
    |> validate_required(:todo_text)
    |> validate_required(:due_date)
    |> set_completed_changed_at()
    |> set_completed_changed_by("admin")
    |> set_deleted_at()
    |> priority_requires_milestone()
    |> milestone_not_deleted()
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
    |> validate_inclusion(:completed_changed_by, ["mentee", "mentor", "parent", "admin"])
    |> set_completed_changed_at()
  end

  def priority_requires_milestone(changeset) do
    if get_field(changeset, :is_priority) == true && get_field(changeset, :is_milestone) == false do
      add_error(changeset, :is_priority, "Only milestone-todos can be marked as priority")
    else
      changeset
    end
  end

  def milestone_not_deleted(changeset) do
    if get_field(changeset, :is_milestone) == true && !is_nil(get_field(changeset, :deleted_at)) do
      add_error(changeset, :is_milestone, "Deleted todos cannot be milestones")
    else
      changeset
    end
  end

  # Make sure this is above milestone_not_deleted
  def set_deleted_at(changeset) do
    case fetch_change(changeset, :deleted) do
      {:ok, true} ->
        put_change(changeset, :deleted_at, NaiveDateTime.local_now())

      {:ok, false} ->
        put_change(changeset, :deleted_at, nil)

      :error ->
        changeset
    end
  end

  def set_completed_changed_at(changeset) do
    case fetch_change(changeset, :completed) do
      {:ok, _} ->
        put_change(changeset, :completed_changed_at, NaiveDateTime.local_now())

      :error ->
        changeset
    end
  end

  def set_completed_changed_by(changeset, who) do
    case fetch_change(changeset, :completed) do
      {:ok, _} ->
        put_change(changeset, :completed_changed_by, who)

      :error ->
        changeset
    end
  end
end
