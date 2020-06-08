defmodule Tzn.Repo.Migrations.CreateTimesheetEntries do
  use Ecto.Migration

  def change do
    create table(:timesheet_entries) do
      add :date, :naive_datetime
      add :notes, :string
      add :hours, :float
      add :mentor_id, references(:mentors, on_delete: :nothing)
      add :mentee_id, references(:mentees, on_delete: :nothing)

      timestamps()
    end

    create index(:timesheet_entries, [:mentor_id])
    create index(:timesheet_entries, [:mentee_id])
  end
end
