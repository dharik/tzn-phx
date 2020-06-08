defmodule Tzn.Repo.Migrations.CreateMentees do
  use Ecto.Migration

  def change do
    create table(:mentees) do
      add :name, :string
      add :mentor_id, references(:mentors, on_delete: :nothing)

      timestamps()
    end

    create index(:mentees, [:mentor_id])
  end
end
