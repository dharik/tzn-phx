defmodule Tzn.Transizion.Mentee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentees" do
    field :name, :string
    belongs_to :mentor, Tzn.Transizion.Mentor
    has_many :timesheet_entries, Tzn.Transizion.TimesheetEntry
    has_many :strategy_sessions, Tzn.Transizion.StrategySession
    has_many :contract_purchases, Tzn.Transizion.ContractPurchase
    timestamps()
  end

  # Admin changeset
  @doc false
  def changeset(mentee, attrs) do
    mentee
    |> cast(attrs, [:name, :mentor_id])
    |> validate_required([:name, :mentor_id])
  end
end
