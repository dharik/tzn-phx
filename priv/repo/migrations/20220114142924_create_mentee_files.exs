defmodule Tzn.Repo.Migrations.CreateMenteeFiles do
  use Ecto.Migration

  def change do
    create table(:mentee_files) do
      add :mentee_id, references(:mentees, on_delete: :delete_all)
      add :deleted_at, :naive_datetime

      add :object_path, :string, null: false

      add :file_name, :string, null: false
      add :file_size, :integer, null: false
      add :file_content_type, :string

      add :uploaded_by, references(:users, on_delete: :nilify_all)
      add :questionnaire_id, references(:questionnaires, on_delete: :nilify_all)

      timestamps()
    end

    create index(:mentee_files, [:mentee_id])
    create index(:mentee_files, [:questionnaire_id])
  end
end
