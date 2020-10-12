defmodule Tzn.Repo.Migrations.AddStatusToMentorTimelineEventMarking do
  use Ecto.Migration

  def change do
    alter table :mentor_timeline_event_markings do
      add :status, :string
    end
  end
end
