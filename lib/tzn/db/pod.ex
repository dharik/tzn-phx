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
    has_many :todos, Tzn.DB.PodTodo
    has_many :flags, Tzn.DB.PodFlag

    has_one :hour_counts, Tzn.Transizion.PodHourCounts

    belongs_to :timeline, Tzn.DB.Timeline

    many_to_many :pod_groups, Tzn.DB.PodGroup,
      join_through: Tzn.DB.PodToPodGroup,
      join_keys: [pod_id: :id, pod_group_id: :id],
      on_replace: :delete

    # has_many :parents, through: [:mentee, :parents]

    field :active, :boolean

    field :type, :string
    field :internal_note, :string
    field :mentor_rate, :decimal

    # features
    # Keep these fields for now
    field :college_list_access, :boolean, default: false # Deprecated in favor of college_list_limit
    field :ecvo_list_access, :boolean, default: false # Deprecated in favor of ecvo_list_limit
    field :scholarship_list_access, :boolean, default: false # Deprecated in favor of scholarship_list_limit

    field :college_list_limit, :integer, default: 1
    field :ecvo_list_limit, :integer, default: 0
    field :scholarship_list_limit, :integer, default: 0

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
      :college_list_limit,
      :ecvo_list_limit,
      :scholarship_list_limit,
      :mentee_id,
      :mentor_id,
      :timeline_id,
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
    |> foreign_key_constraint(:timeline_id)
    |> validate_number(:hours_recommended_freshman, greater_than_or_equal_to: 0)
    |> validate_number(:hours_recommended_sophomore, greater_than_or_equal_to: 0)
    |> validate_number(:hours_recommended_junior, greater_than_or_equal_to: 0)
    |> validate_number(:hours_recommended_senior, greater_than_or_equal_to: 0)
    |> validate_number(:hours_cap_freshman, greater_than_or_equal_to: 0)
    |> validate_number(:hours_cap_sophomore, greater_than_or_equal_to: 0)
    |> validate_number(:hours_cap_junior, greater_than_or_equal_to: 0)
    |> validate_number(:hours_cap_senior, greater_than_or_equal_to: 0)
    |> validate_number(:college_list_limit, less_than: 10, greater_than_or_equal_to: -1)
    |> validate_number(:ecvo_list_limit, less_than: 10, greater_than_or_equal_to: -1)
    |> validate_number(:scholarship_list_limit, less_than: 10, greater_than_or_equal_to: -1)
  end

  # TODO: Recommended hours/year cannot exceed the capped hours
end
