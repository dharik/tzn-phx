defmodule Tzn.Repo.Migrations.CreateEverything do
  use Ecto.Migration

  def change do
    create table(:users) do
      add :email, :string, null: false
      add :password_hash, :string

      timestamps()
    end
    create unique_index(:users, [:email])


    create table(:mentors) do
      add :name, :string
      add :user_id, references(:users, on_delete: :nothing)
      timestamps()
    end

    create table(:mentees) do
      add :name, :string
      add :internal_name, :string
      add :internal_note, :string
      add :mentor_id, references(:mentors, on_delete: :nothing)
      add :user_id, references(:users, on_delete: :nothing)

      timestamps()
    end

    create index(:mentees, [:mentor_id])

    create table(:strategy_sessions) do
      add :published, :boolean, default: false, null: false
      add :date, :naive_datetime
      add :title, :string
      add :email_subject, :string
      add :notes, :string
      add :mentor_id, references(:mentors, on_delete: :nothing)
      add :mentee_id, references(:mentees, on_delete: :nothing)

      timestamps()
    end

    create index(:strategy_sessions, [:mentor_id])
    create index(:strategy_sessions, [:mentee_id])

    create table(:timesheet_entries) do
      add :started_at, :naive_datetime
      add :ended_at, :naive_datetime
      add :notes, :string
      add :hours, :decimal
      add :mentor_id, references(:mentors, on_delete: :nothing)
      add :mentee_id, references(:mentees, on_delete: :nothing)

      timestamps()
    end

    create index(:timesheet_entries, [:mentor_id])
    create index(:timesheet_entries, [:mentee_id])


    create table(:admins) do
      add :user_id, references(:users, on_delete: :delete_all)

      timestamps()
    end

    create index(:admins, [:user_id])

    create table(:contract_purchases) do
      add :mentee_id, references(:mentees, on_delete: :nothing)

      add :hours, :float
      add :date, :naive_datetime
      add :notes, :string
      timestamps()
    end
  end
end
