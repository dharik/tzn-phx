defmodule Tzn.Repo.Migrations.CreatePodFlags do
  use Ecto.Migration

  def change do
    create table(:pod_flags) do
      add :pod_id, references(:pods, on_delete: :delete_all)

      add :status, :string, null: false
      add :description, :text
      add :parent_can_read, :boolean
      add :school_admin_can_read, :boolean

      timestamps()
    end

    create index(:pod_flags, [:pod_id])
  end
end
