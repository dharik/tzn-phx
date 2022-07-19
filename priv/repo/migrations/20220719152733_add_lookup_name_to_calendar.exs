defmodule Tzn.Repo.Migrations.AddLookupNameToCalendar do
  use Ecto.Migration

  def change do
    alter table(:calendars) do
      add :lookup_name, :string
    end
  end
end
