defmodule Tzn.Repo.Migrations.AddTodoListsToMentee do
  use Ecto.Migration

  def change do
    alter table(:mentees) do
      add :mentor_todo_notes, :text
      add :parent_todo_notes, :text
      add :mentee_todo_notes, :text
    end
  end
end
