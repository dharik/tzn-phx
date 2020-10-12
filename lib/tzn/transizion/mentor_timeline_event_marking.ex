defmodule Tzn.Transizion.MentorTimelineEventMarking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentor_timeline_event_markings" do
    field :notes, :string
    belongs_to :mentee, Tzn.Transizion.Mentee 
    belongs_to :mentor_timeline_event, Tzn.Transizion.MentorTimelineEvent

    timestamps()
  end

  @doc false
  def changeset(mentor_timeline_event, attrs) do
    mentor_timeline_event
    |> cast(attrs, [:mentee_id, :mentor_timeline_event_id, :notes])
    |> validate_required([:mentor_id, :mentor_timeline_event_id])
  end
end
