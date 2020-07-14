defmodule Tzn.Transizion.Timeline do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timelines" do
    field :published, :boolean
    field :title, :string
    field :slug, :string
    has_many :timeline_events, Tzn.Transizion.TimelineEvent
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
