defmodule Tzn.DB.CalendarEventMarking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "calendar_event_markings" do
    belongs_to :calendar_event, Tzn.DB.CalendarEvent
    belongs_to :timeline, Tzn.DB.Timeline

    field :completed_at, :naive_datetime
    field :hidden_at, :naive_datetime

    timestamps()
  end

  @doc false
  def changeset(marking, attrs) do
    marking
    |> cast(attrs, [:calendar_event_id, :timeline_id, :completed_at, :hidden_at])
    |> validate_required([:calendar_event_id, :timeline_id])
  end
end
