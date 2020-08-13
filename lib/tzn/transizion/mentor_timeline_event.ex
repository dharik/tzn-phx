defmodule Tzn.Transizion.MentorTimelineEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentor_timeline_events" do
    field :date, :naive_datetime
    field :grade, :string
    field :is_hard_deadline, :boolean, default: false
    field :notes, :string

    timestamps()
  end

  @doc false
  def changeset(mentor_timeline_event, attrs) do
    mentor_timeline_event
    |> cast(attrs, [:notes, :grade, :is_hard_deadline, :date])
    |> validate_required([:notes, :grade, :is_hard_deadline, :date])
  end
end
