defmodule Tzn.Repo.Migrations.CreateStrategySessions do
  use Ecto.Migration

  def change do
    create table(:strategy_sessions) do
      add :published, :boolean, default: false, null: false
      add :date, :naive_datetime
      add :title, :string
      add :notes, :string
      add :mentor_id, references(:mentors, on_delete: :nothing)
      add :mentee_id, references(:mentees, on_delete: :nothing)

      timestamps()
    end

    create index(:strategy_sessions, [:mentor_id])
    create index(:strategy_sessions, [:mentee_id])
  end
end
