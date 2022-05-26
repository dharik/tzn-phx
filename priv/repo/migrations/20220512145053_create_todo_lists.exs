defmodule Tzn.Repo.Migrations.CreateTodoLists do
  use Ecto.Migration

  def change do
    create table(:pod_todos) do
      add :pod_id, references(:pods, on_delete: :delete_all), null: false

      add :todo_text, :text, null: false

      add :completed, :boolean, null: false, default: false
      add :completed_changed_at, :naive_datetime
      add :completed_changed_by, :string # mentor, mentee, parent

      add :due_date, :date
      add :assignee_type, :string # mentor, mentee, parent

      add :deleted_at, :naive_datetime

      timestamps()
    end

    create index(:pod_todos, [:pod_id, :completed])
    create index(:pod_todos, [:completed_changed_at])
    create index(:pod_todos, [:due_date])
    create index(:pod_todos, [:updated_at])
  end
end
