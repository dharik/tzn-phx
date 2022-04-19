defmodule Tzn.Pod do
  use Ecto.Schema
  import Ecto.Query
  import Ecto.Changeset
  alias Tzn.Transizion.MenteeChanges
  alias Tzn.Repo

  # Todo: eventually have its own table
  schema "mentees" do
    # belongs_to :mentee, Tzn.Transizion.Mentee
    field :mentee, :any, virtual: true
    belongs_to :mentor, Tzn.Transizion.Mentor

    has_many :contract_purchases, Tzn.Transizion.ContractPurchase, foreign_key: :mentee_id
    has_many :timesheet_entries, Tzn.Transizion.TimesheetEntry, foreign_key: :mentee_id
    has_many :strategy_sessions, Tzn.Transizion.StrategySession, foreign_key: :mentee_id
    has_many :questionnaires, Tzn.Questionnaire.Questionnaire, foreign_key: :mentee_id
    has_many :answers, Tzn.Questionnaire.Answer, foreign_key: :mentee_id

    has_one :hour_counts, Tzn.Transizion.MenteeHourCounts, foreign_key: :mentee_id

    has_many :parents, Tzn.Transizion.Parent, foreign_key: :mentee_id

    # field :archive_status, :string
    field :archived, :boolean
    field :archived_reason, :string

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

    timestamps()
  end

  # This is usually for admin so we're not going to load everything
  def list_pods(:mentor) do
    # hour_counts, mentor, parents, mentee
  end

  def list_pods(:admin) do
    # hour_counts, mentor, parents, mentee
  end

  def get_pod(nil) do
    nil
  end

  def get_pod!(id) do
    pod =
      Repo.get!(__MODULE__, id)
      |> Repo.preload([
        :timesheet_entries,
        :contract_purchases,
        :questionnaires,
        :strategy_sessions,
        :hour_counts,
        :mentor,
        :parents
      ])

    # Inject the mentee since there isn't a pods table yet
    # pod id = mentee id
    mentee = Tzn.Mentee.get_mentee(pod.id)
    pod |> Map.put(:mentee, mentee)
  end

  def get_pod(id) do
    pod =
      Repo.get(__MODULE__, id)
      |> Repo.preload([
        :timesheet_entries,
        :contract_purchases,
        :questionnaires,
        :strategy_sessions,
        :hour_counts,
        :mentor,
        :parents
      ])

    # Inject the mentee since there isn't a pods table yet
    # pod id = mentee id
    mentee = Tzn.Mentee.get_mentee(pod.id)
    pod |> Map.put(:mentee, mentee)
  end

  def change_pod(%__MODULE__{} = pod, attrs \\ %{}) do
    pod
    |> cast(attrs, [
      :timesheet_entries,
      :contract_purchases,
      :questionnaires,
      :strategy_sessions,
      :mentor,
      :mentor_rate,
      # :archived, :archived_reason # this needs to be moved from mentee
      # :internal_note,
      :mentor_todo_notes,
      :parent_todo_notes,
      :mentee_todo_notes,
      :college_list_access,
      :ecvo_list_access,
      :scholarship_list_access
    ])
  end

  def most_recent_todo_list_updated_at(nil) do
    nil
  end

  def most_recent_todo_list_updated_at(%__MODULE__{} = mentee) do
    Repo.one(
      from(mc in MenteeChanges,
        where: mc.field in ["parent_todo_notes", "mentee_todo_notes", "mentor_todo_notes"],
        where: mc.mentee_id == ^mentee.id,
        select: max(mc.updated_at)
      )
    )
  end
end
