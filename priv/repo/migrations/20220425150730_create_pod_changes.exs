defmodule Tzn.Repo.Migrations.CreatePodChanges do
  use Ecto.Migration

  def change do
    create table(:pod_changes) do
      add :pod_id, references(:pods, on_delete: :delete_all), null: false
      add :changed_by, references(:users, on_delete: :nilify_all)

      add :field, :text, null: false
      add :old_value, :text
      add :new_value, :text

      timestamps()
    end

    create index(:pod_changes, [:pod_id, :field, :updated_at])
    create index(:pod_changes, [:field, :updated_at])
    create index(:pod_changes, [:updated_at])
  end
end
