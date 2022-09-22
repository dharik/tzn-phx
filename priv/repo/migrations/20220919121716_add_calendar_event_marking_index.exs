defmodule Tzn.Repo.Migrations.AddCalendarEventMarkingIndex do
  use Ecto.Migration

  def change do
    create index(:calendar_event_markings, [:timeline_id])
    create index(:calendar_event_markings, [:calendar_event_id])
  end
end
