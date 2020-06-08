defmodule Tzn.Transizion.TimesheetEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timesheet_entries" do
    field :date, :naive_datetime
    field :hours, :decimal
    field :notes, :string
    field :mentor_id, :id
    field :mentee_id, :id

    timestamps()
  end

  @doc false
  def changeset(timesheet_entry, attrs) do
    timesheet_entry
    |> cast(attrs, [:date, :notes, :hours])
    |> validate_required([:date, :notes, :hours])
  end
end
