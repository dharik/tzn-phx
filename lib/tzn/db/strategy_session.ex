defmodule Tzn.Transizion.StrategySession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "strategy_sessions" do
    field :date, :naive_datetime
    field :notes, :string
    field :published, :boolean, default: false
    field :emailed, :boolean, default: false
    field :email_subject, :string
    belongs_to :mentor, Tzn.Transizion.Mentor
    belongs_to :mentee, Tzn.Transizion.Mentee

    field :cc_mentee, :boolean, default: true

    timestamps()
  end

  @doc false
  def changeset(strategy_session, attrs) do
    strategy_session
    |> cast(attrs, [:published, :date, :notes, :mentee_id, :mentor_id, :email_subject, :emailed, :cc_mentee])
    |> validate_required([:published, :date, :notes, :mentee_id, :mentor_id, :email_subject, :cc_mentee])
  end

  def email_sent_changeset(strategy_session) do
    strategy_session
    |> cast(%{emailed: true}, [:emailed])
  end
end
