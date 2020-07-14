defmodule Tzn.Transizion.TimelineEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timeline_events" do
    field :notes, :string
    field :date, :naive_datetime
    field :is_hard_deadline, :boolean
    
    belongs_to :timeline, Tzn.Transizion.Timeline
    timestamps()
  end

  @doc false
  def changeset(strategy_session, attrs) do
    strategy_session
    |> cast(attrs, [:published, :title, :slug])
    |> validate_required([:published, :slug])
    # Slug is unique check
  end
end
