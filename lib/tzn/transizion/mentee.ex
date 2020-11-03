defmodule Tzn.Transizion.Mentee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentees" do
    field :name, :string
    field :email, :string

    field :internal_note, :string

    field :parent1_email, :string
    field :parent1_name, :string

    field :parent2_email, :string
    field :parent2_name, :string

    field :grade, :string

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
    |> cast(attrs, [
      :internal_note,
      :parent1_email,
      :parent1_name,
      :parent2_email,
      :parent2_name,
      :grade
    ])
  end

  def admin_changeset(mentee, attrs) do
    mentee
    |> cast(attrs, [
      :name,
      :internal_note,
      :parent1_email,
      :parent1_name,
      :parent2_email,
      :parent2_name,
      :mentor_id,
      :user_id,
      :grade,
      :email
    ])
    |> cast_assoc(:user)
    |> validate_required([:name])
  end
end
