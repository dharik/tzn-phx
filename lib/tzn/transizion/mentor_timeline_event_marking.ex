defmodule Tzn.Transizion.MentorTimelineEventMarking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentor_timeline_event_markings" do
    field :notes, :string
    field :completed_for_mentees, {:array, :integer}

    belongs_to :mentor, Tzn.Transizion.Mentor
    belongs_to :mentor_timeline_event, Tzn.Transizion.MentorTimelineEvent

    timestamps()
  end

  @doc false
  def changeset(mentor_timeline_event, attrs) do
    mentor_timeline_event
    |> cast(attrs, [:completed_for_mentees, :mentor_id, :mentor_timeline_event_id, :notes])
    |> set_default_completed_for_mentees(attrs)
    |> validate_required([:completed_for_mentees, :mentor_id, :mentor_timeline_event_id])
  end

  # Use an empty array if completed_for_mentees doesn't exist
  def set_default_completed_for_mentees(changeset, attrs) do
    if attrs |> Map.get("completed_for_mentees") do
      changeset
    else
      changeset |> put_change(:completed_for_mentees, [])
    end
  end
end
