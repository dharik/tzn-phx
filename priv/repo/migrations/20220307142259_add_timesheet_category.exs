defmodule Tzn.Repo.Migrations.AddTimesheetCategory do
  use Ecto.Migration

  def change do
    alter table(:mentees) do
      add :type, :string

    end

    alter table(:timesheet_entries) do
      add :category, :string
    end
  end
end
