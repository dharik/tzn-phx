defmodule Tzn.Repo.Migrations.AddRateToTimesheetEntries do
  use Ecto.Migration

  def change do
    alter table :timesheet_entries do
      add :hourly_rate, :decimal
    end
  end
end
