defmodule Tzn.DB.TimelineCalendar do
  use Ecto.Schema
  import Ecto.Changeset

  @primary_key false
  schema "timelines_calendars" do
    belongs_to :timeline, Tzn.DB.Timeline
    belongs_to :calendar, Tzn.DB.Calendar
  end

  def changeset(c, params \\ %{}) do
    c
    |> cast(params, [:timeline_id, :calendar_id])
    |> validate_required([:timeline_id, :calendar_id])
  end
end
