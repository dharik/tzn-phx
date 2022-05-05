defmodule Tzn.Transizion.Mentee do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentees" do
    field :name, :string
    field :nick_name, :string
    field :pronouns, :string
    field :timezone_offset, :integer

    field :email, :string
    field :archived, :boolean
    field :archived_reason, :string
    field :type, :string

    field :internal_note, :string

    # TODO: remove these because they go with the pod now
    field :mentor_todo_notes, :string
    field :parent_todo_notes, :string
    field :mentee_todo_notes, :string

    field :parent1_email, :string
    field :parent1_name, :string

    field :parent2_email, :string
    field :parent2_name, :string

    field :grade, :string

    # TODO: Remove these since they go with the Pod now
    field :college_list_access, :boolean, default: false
    field :ecvo_list_access, :boolean, default: false
    field :scholarship_list_access, :boolean, default: false

    # TODO: Remove since it goes iwth the pod
    belongs_to :mentor, Tzn.Transizion.Mentor

    # TODO: Remove since it goes with the Pod
    field :mentor_rate, :decimal

    belongs_to :user, Tzn.Users.User

    # TODO: Remove these 3
    has_many :timesheet_entries, Tzn.Transizion.TimesheetEntry
    has_many :strategy_sessions, Tzn.Transizion.StrategySession
    has_many :contract_purchases, Tzn.Transizion.ContractPurchase

    has_many :questionnaires, Tzn.Questionnaire.Questionnaire
    has_many :answers, Tzn.Questionnaire.Answer
    has_many :parents, Tzn.Transizion.Parent
    has_many :changes, Tzn.Transizion.MenteeChanges
    has_many :pods, Tzn.DB.Pod

    timestamps()
  end

  @doc false
  def changeset(mentee, attrs) do
    mentee
    |> cast(attrs, [
      :nick_name,
      :pronouns,
      :timezone_offset,
      :internal_note,
      :parent1_email,
      :parent1_name,
      :parent2_email,
      :parent2_name,
      :grade
    ])
    |> to_lowercase(:parent1_email)
    |> to_lowercase(:parent2_email)
    |> validate_parent1()
    |> validate_parent2()
  end

  def admin_changeset(mentee, attrs) do
    mentee
    |> cast(attrs, [
      :name,
      :nick_name,
      :pronouns,
      :timezone_offset,
      :internal_note,
      :parent1_email,
      :parent1_name,
      :parent2_email,
      :parent2_name,
      :user_id,
      :grade,
      :email,
      :archived,
      :archived_reason,
    ])
    |> to_lowercase(:parent1_email)
    |> to_lowercase(:parent2_email)
    |> to_lowercase(:email)
    |> cast_assoc(:user)
    |> validate_required([:name])
    |> validate_parent1()
    |> validate_parent2()
    |> validate_archived_reason()
  end

  def to_lowercase(changeset, fieldname) do
    case fetch_change(changeset, fieldname) do
      {:ok, value} when is_binary(value) ->
        put_change(changeset, fieldname, String.downcase(value))

      {:ok, value} when is_nil(value) ->
        changeset

      :error ->
        changeset
    end
  end

  def validate_archived_reason(changeset) do
    if get_field(changeset, :archived) == true do
      validate_required(changeset, :archived_reason)
    else
      put_change(changeset, :archived_reason, nil)
    end
  end

  def validate_parent1(changeset) do
    parent1_name = get_field(changeset, :parent1_name)
    parent1_email = get_field(changeset, :parent1_email)

    name_is_set = parent1_name && parent1_name !== ""
    email_is_set = parent1_email && parent1_email !== ""

    cond do
      name_is_set && email_is_set -> changeset
      name_is_set && !email_is_set -> add_error(changeset, :parent1_email, "required")
      !name_is_set && email_is_set -> add_error(changeset, :parent1_name, "required")
      !name_is_set && !email_is_set -> changeset
    end
  end

  def validate_parent2(changeset) do
    parent2_name = get_field(changeset, :parent2_name)
    parent2_email = get_field(changeset, :parent2_email)

    name_is_set = parent2_name && parent2_name !== ""
    email_is_set = parent2_email && parent2_email !== ""

    cond do
      name_is_set && email_is_set -> changeset
      name_is_set && !email_is_set -> add_error(changeset, :parent2_email, "required")
      !name_is_set && email_is_set -> add_error(changeset, :parent2_name, "required")
      !name_is_set && !email_is_set -> changeset
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
