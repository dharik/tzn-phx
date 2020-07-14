defmodule Tzn.Transizion.Mentee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentees" do
    field :name, :string
    field :internal_name, :string
    field :internal_note, :string

    belongs_to :mentor, Tzn.Transizion.Mentor
    belongs_to :user, Tzn.Users.User

    has_many :timesheet_entries, Tzn.Transizion.TimesheetEntry
    has_many :strategy_sessions, Tzn.Transizion.StrategySession
    has_many :contract_purchases, Tzn.Transizion.ContractPurchase
    has_one :hour_counts, Tzn.Transizion.MenteeHourCounts

    timestamps()
  end

  @doc false
  def changeset(mentee, attrs) do
    mentee
    |> cast(attrs, [:internal_name, :internal_note])
  end

  def admin_changeset(mentee, attrs) do
    mentee
    |> cast(attrs, [:internal_name, :internal_note, :mentor])
  end
end
