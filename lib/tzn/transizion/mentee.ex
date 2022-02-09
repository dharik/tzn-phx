defmodule Tzn.Transizion.Mentee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentees" do
    field :name, :string
    field :email, :string
    field :archived, :boolean

    field :internal_note, :string

    field :mentor_todo_notes, :string
    field :parent_todo_notes, :string
    field :mentee_todo_notes, :string

    field :parent1_email, :string
    field :parent1_name, :string

    field :parent2_email, :string
    field :parent2_name, :string

    field :grade, :string

    belongs_to :mentor, Tzn.Transizion.Mentor

    # Rates can change and this allows for overriding the mentor's rate
    field :mentor_rate, :decimal

    belongs_to :user, Tzn.Users.User

    has_many :timesheet_entries, Tzn.Transizion.TimesheetEntry
    has_many :strategy_sessions, Tzn.Transizion.StrategySession
    has_many :contract_purchases, Tzn.Transizion.ContractPurchase
    has_one :hour_counts, Tzn.Transizion.MenteeHourCounts

    has_many :questionnaires, Tzn.Questionnaire.Questionnaire
    has_many :answers, Tzn.Questionnaire.Answer
    has_many :parents, Tzn.Transizion.Parent

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
      :grade,
      :mentor_todo_notes,
      :parent_todo_notes,
      :mentee_todo_notes
    ])
    |> to_lowercase(:parent1_email)
    |> to_lowercase(:parent2_email)
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
      :mentor_rate,
      :user_id,
      :grade,
      :email,
      :archived
    ])
    |> to_lowercase(:parent1_email)
    |> to_lowercase(:parent2_email)
    |> to_lowercase(:email)
    |> cast_assoc(:user)
    |> validate_required([:name])
  end

  def to_lowercase(changeset, fieldname) do
    case fetch_change(changeset, fieldname) do
      {:ok, value} when is_binary(value) -> put_change(changeset, fieldname, String.downcase(value))
      {:ok, value} when is_nil(value) -> changeset
      :error -> changeset
    end
  end

  def parent_names(%{parent1_name: nil, parent2_name: nil}) do
    ""
  end

  def parent_names(%{parent1_name: p1, parent2_name: nil}) do
    p1
  end

  def parent_names(%{parent1_name: nil, parent2_name: p2}) do
    p2
  end

  def parent_names(%{parent1_name: p1, parent2_name: p2}) when is_binary(p1) and is_binary(p2) do
    p1 <> " and " <> p2
  end
end
