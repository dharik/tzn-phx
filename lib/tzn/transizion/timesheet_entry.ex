defmodule Tzn.Transizion.TimesheetEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timesheet_entries" do
    field :started_at, :naive_datetime
    field :ended_at, :naive_datetime
    field :notes, :string
    field :hourly_rate, :decimal
    belongs_to :mentor, Tzn.Transizion.Mentor
    belongs_to :mentee, Tzn.Transizion.Mentee

    timestamps()
  end

  @doc false
  def changeset(timesheet_entry, attrs) do
    timesheet_entry
    |> cast(attrs, [:started_at, :ended_at, :notes, :mentor_id, :mentee_id, :hourly_rate])
    |> validate_required([:started_at, :ended_at, :notes, :mentor_id])
    |> ended_after_started()
    |> duration_is_reasonable()
  end

  def ended_after_started(changeset) do
    validate_change(changeset, :ended_at, fn (:ended_at, _value) ->
      started_at = get_field(changeset, :started_at)
      ended_at = get_field(changeset, :ended_at)

      if NaiveDateTime.compare(ended_at, started_at) != :gt do
        [ended_at: "must end after start time"]
      else
        []
      end
    end)
  end

  def duration_is_reasonable(changeset) do
    validate_change(changeset, :ended_at, fn (:ended_at, _value) ->
      started_at = get_field(changeset, :started_at)
      ended_at = get_field(changeset, :ended_at)

      if NaiveDateTime.diff(ended_at, started_at, :second) > 3600 * 3 do
        [ended_at: "shouldn't be greater than 3 hours"]
      else
        []
      end
    end)
  end
end
