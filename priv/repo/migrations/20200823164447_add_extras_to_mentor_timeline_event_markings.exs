defmodule Tzn.Repo.Migrations.AddExtrasToMentorTimelineEventMarkings do
  use Ecto.Migration

  def change do
    alter table :mentor_timeline_event_markings do
      remove :completed
      add :completed_for_mentees, {:array, :integer}, default: []
    end
  end
end
