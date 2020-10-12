defmodule Tzn.Transizion.MentorTimelineEventMarking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentor_timeline_event_markings" do
    field :notes, :string
    field :status, :string
    belongs_to :mentee, Tzn.Transizion.Mentee 
    belongs_to :mentor_timeline_event, Tzn.Transizion.MentorTimelineEvent

    timestamps()
  end

  @doc false
  def changeset(mentor_timeline_event, attrs) do
    mentor_timeline_event
    |> cast(attrs, [:mentee_id, :mentor_timeline_event_id, :notes, :status])
    |> validate_inclusion(:status, ["incomplete", "in_progress", "complete"])
    |> validate_required([:mentor_id, :mentor_timeline_event_id, :status])
  end
end
