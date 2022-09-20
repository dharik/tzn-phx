defmodule Tzn.Repo.Migrations.CreatePodGroups do
  use Ecto.Migration

  def change do
    create table(:pod_groups) do
      add :name, :string, null: false
      add :admin_notes, :text
      add :expected_size, :integer

      timestamps()
    end

    create table(:school_admins) do
      add :name, :string
      add :nick_name, :string
      add :pronouns, :string
      add :email, :string

      add :user_id, references(:users, on_delete: :nilify_all)

      timestamps()
    end
    create index(:school_admins, [:user_id])

    create table(:pod_groups_to_profiles) do
      add :pod_group_id, references(:pod_groups, on_delete: :delete_all)
      add :school_admin_id, references(:school_admins, on_delete: :delete_all)

      timestamps()
    end
    create index(:pod_groups_to_profiles, [:pod_group_id])
    create index(:pod_groups_to_profiles, [:school_admin_id])


    create table(:pods_to_pod_groups) do
      add :pod_id, references(:pods, on_delete: :delete_all)
      add :pod_group_id, references(:pod_groups, on_delete: :delete_all)

      timestamps()
    end
    create index(:pods_to_pod_groups, [:pod_group_id])
    create index(:pods_to_pod_groups, [:pod_id])
  end
end
