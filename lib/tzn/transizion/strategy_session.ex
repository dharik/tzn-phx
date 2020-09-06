defmodule Tzn.Transizion.StrategySession do
  use Ecto.Schema
  import Ecto.Changeset

  schema "strategy_sessions" do
    field :date, :naive_datetime
    field :notes, :string
    field :published, :boolean, default: false
    field :emailed, :boolean, default: false
    field :title, :string
    field :email_subject, :string
    belongs_to :mentor, Tzn.Transizion.Mentor
    belongs_to :mentee, Tzn.Transizion.Mentee

    timestamps()
  end

  @doc false
  def changeset(strategy_session, attrs) do
    strategy_session
    |> cast(attrs, [:published, :date, :title, :notes, :mentee_id, :mentor_id, :email_subject])
    |> validate_required([:published, :date, :title, :notes, :mentee_id, :mentor_id, :email_subject])
  end

  def email_sent_changeset(strategy_session) do
    strategy_session
    |> cast(%{emailed: true}, [:emailed])
  end
end
