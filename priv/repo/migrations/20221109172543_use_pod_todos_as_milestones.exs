defmodule Tzn.Repo.Migrations.UsePodTodosAsMilestones do
  use Ecto.Migration

  def change do
    alter table(:pod_todos) do
      add :is_milestone, :boolean, default: false
      add :is_priority, :boolean, default: false
    end
  end
end
