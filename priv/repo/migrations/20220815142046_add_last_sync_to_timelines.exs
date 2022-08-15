defmodule Tzn.Repo.Migrations.AddLastSyncToTimelines do
  use Ecto.Migration

  def change do
    alter table(:timelines) do
      add :last_ical_sync_at, :naive_datetime
      add :last_ical_sync_client, :string
    end
  end
end
