defmodule Tzn.Repo.Migrations.CreateMentorTimelineEvents do
  use Ecto.Migration

  def change do
    create table(:mentor_timeline_events) do
      add :notes, :string
      add :grade, :string
      add :is_hard_deadline, :boolean, default: false, null: false
      add :date, :naive_datetime

      timestamps()
    end

    create table(:mentor_timeline_event_markings) do
      add :mentor_id, references(:mentors, on_delete: :delete_all)
      add :mentor_timeline_event_id, references(:mentor_timeline_events, on_delete: :delete_all)
      add :completed, :boolean

      timestamps()
    end

  end
end
