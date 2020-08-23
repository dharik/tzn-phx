defmodule Tzn.Repo.Migrations.AddNotesToMentorTimelineEventMarking do
  use Ecto.Migration

  def change do
    alter table :mentor_timeline_event_markings do
      add :notes, :text
    end
  end
end
