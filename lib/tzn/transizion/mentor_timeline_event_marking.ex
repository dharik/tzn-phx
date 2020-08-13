defmodule Tzn.Transizion.MentorTimelineEventMarking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentor_timeline_event_markings" do
    field :completed, :boolean
    belongs_to :mentor, Tzn.Transizion.Mentor
    belongs_to :mentor_timeline_event, Tzn.Transizion.MentorTimelineEvent

    timestamps()
  end

  @doc false
  def changeset(mentor_timeline_event, attrs) do
    mentor_timeline_event
    |> cast(attrs, [:completed, :mentor_id, :mentor_timeline_event_id])
    |> validate_required([:completed, :mentor_id, :mentor_timeline_event_id])
  end
end
