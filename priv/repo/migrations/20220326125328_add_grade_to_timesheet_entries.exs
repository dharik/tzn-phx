defmodule Tzn.Repo.Migrations.AddGradeToTimesheetEntries do
  use Ecto.Migration

  def change do
    alter table :timesheet_entries do
      add :mentee_grade, :string
    end
  end
end
