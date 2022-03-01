defmodule Tzn.Repo.Migrations.MenteeChangeTracking do
  use Ecto.Migration

  def change do
    create table(:mentee_changes) do
      add :mentee_id, references(:mentees, on_delete: :delete_all), null: false
      add :changed_by, references(:users, on_delete: :nilify_all)

      add :field, :text, null: false
      add :new_value, :text

      timestamps()
    end

    create index(:mentee_changes, [:mentee_id, :field, :updated_at])
    create index(:mentee_changes, [:field, :updated_at])
    create index(:mentee_changes, [:updated_at])
  end
end
