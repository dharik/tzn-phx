defmodule Tzn.Transizion.Mentor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentors" do
    field :name, :string
    has_many :mentees, Tzn.Transizion.Mentee
    has_many :timesheet_entries, Tzn.Transizion.TimesheetEntry
    has_many :strategy_sessions, Tzn.Transizion.StrategySession
    timestamps()
  end

  @doc false
  def changeset(mentor, attrs) do
    mentor
    |> cast(attrs, [:name])
    |> validate_required([:name])
  end
end
