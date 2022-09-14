defmodule Tzn.Repo.Migrations.CreateCalendarEventMarkings do
  use Ecto.Migration

  def change do
    create table(:calendar_event_markings) do
      add :calendar_event_id, references(:calendar_events, on_delete: :delete_all)
      add :timeline_id, references(:timelines, on_delete: :delete_all)

      add :completed_at, :naive_datetime
      add :hidden_at, :naive_datetime

      timestamps()
    end
  end
end
