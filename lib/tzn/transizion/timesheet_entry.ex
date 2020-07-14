defmodule Tzn.Transizion.TimesheetEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timesheet_entries" do
    field :date, :naive_datetime
    field :hours, :decimal
    field :notes, :string
    belongs_to :mentor, Tzn.Transizion.Mentor
    belongs_to :mentee, Tzn.Transizion.Mentee

    timestamps()
  end

  @doc false
  def changeset(timesheet_entry, attrs) do
    timesheet_entry
    |> cast(attrs, [:date, :notes, :hours, :mentor_id, :mentee_id])
    |> validate_required([:date, :notes, :hours, :mentor_id])
  end
end
