defmodule Tzn.Repo.Migrations.DropTodoNotesOnPods do
  use Ecto.Migration

  def change do
    alter table(:pods) do
      remove :mentor_todo_notes
      remove :parent_todo_notes
      remove :mentee_todo_notes
    end
  end
end
