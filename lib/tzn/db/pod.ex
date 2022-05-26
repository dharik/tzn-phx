defmodule Tzn.DB.Pod do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pods" do
    belongs_to :mentee, Tzn.Transizion.Mentee
    belongs_to :mentor, Tzn.Transizion.Mentor

    has_many :contract_purchases, Tzn.Transizion.ContractPurchase
    has_many :timesheet_entries, Tzn.Transizion.TimesheetEntry
    has_many :strategy_sessions, Tzn.Transizion.StrategySession
    has_many :questionnaires, through: [:mentee, :questionnaires]
    has_many :answers, through: [:mentee, :answers]
    has_many :changes, Tzn.DB.PodChanges

    has_one :hour_counts, Tzn.Transizion.PodHourCounts

    # has_many :parents, through: [:mentee, :parents]

    field :active, :boolean

    field :type, :string
    field :internal_note, :string
    field :mentor_rate, :decimal

    field :mentor_todo_notes, :string
    field :parent_todo_notes, :string
    field :mentee_todo_notes, :string

    # features
    field :college_list_access, :boolean, default: false
    field :ecvo_list_access, :boolean, default: false
    field :scholarship_list_access, :boolean, default: false

    # hour breakdown by grade
    field :hours_recommended_freshman, :decimal
    field :hours_recommended_sophomore, :decimal
    field :hours_recommended_junior, :decimal
    field :hours_recommended_senior, :decimal
    field :hours_cap_freshman, :decimal
    field :hours_cap_sophomore, :decimal
    field :hours_cap_junior, :decimal
    field :hours_cap_senior, :decimal

    timestamps()
  end

  def changeset(%__MODULE__{} = pod, attrs \\ %{}) do
    pod
    |> cast(attrs, [
      :type,
      :active,
      :mentor_rate,
      :internal_note,
      :mentor_todo_notes,
      :parent_todo_notes,
      :mentee_todo_notes,
      :college_list_access,
      :ecvo_list_access,
      :scholarship_list_access,
      :mentee_id,
      :mentor_id,
      :hours_recommended_freshman,
      :hours_recommended_sophomore,
      :hours_recommended_junior,
      :hours_recommended_senior,
      :hours_cap_freshman,
      :hours_cap_sophomore,
      :hours_cap_junior,
      :hours_cap_senior
    ])
    |> foreign_key_constraint(:mentee_id)
    |> foreign_key_constraint(:mentor_id)
    |> validate_number(:hours_recommended_freshman, greater_than_or_equal_to: 0)
    |> validate_number(:hours_recommended_sophomore, greater_than_or_equal_to: 0)
    |> validate_number(:hours_recommended_junior, greater_than_or_equal_to: 0)
    |> validate_number(:hours_recommended_senior, greater_than_or_equal_to: 0)
    |> validate_number(:hours_cap_freshman, greater_than_or_equal_to: 0)
    |> validate_number(:hours_cap_sophomore, greater_than_or_equal_to: 0)
    |> validate_number(:hours_cap_junior, greater_than_or_equal_to: 0)
    |> validate_number(:hours_cap_senior, greater_than_or_equal_to: 0)
  end

  # TODO: Recommended hours/year cannot exceed the capped hours
end