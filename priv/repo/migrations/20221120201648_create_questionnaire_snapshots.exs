defmodule Tzn.Repo.Migrations.CreateQuestionnaireSnapshots do
  use Ecto.Migration

  def change do
    create table(:questionnaire_snapshots) do
      add :questionnaire_id, references(:questionnaires, on_delete: :delete_all)
      add :state, :string, null: false
      add :snapshot_data, :map
      timestamps()
    end

    create index(:questionnaire_snapshots, [:questionnaire_id])
  end
end
