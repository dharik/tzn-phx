defmodule Tzn.Repo.Migrations.TimelineMarkingPerMentee do
  use Ecto.Migration

  def change do
    alter table :mentor_timeline_event_markings do
      remove :completed_for_mentees
      remove :mentor_id
      add :mentee_id, references(:mentees, on_delete: :delete_all)
    end

  end
end
