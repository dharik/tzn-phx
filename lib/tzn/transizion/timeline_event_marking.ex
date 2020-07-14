defmodule Tzn.Transizion.TimelineEventMarking do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timeline_event_markings" do
    field :completed, :boolean
    
    belongs_to :user, Tzn.Users.User
    belongs_to :timeline_event, Tzn.Transizion.TimelineEvent
    timestamps()
  end

  @doc false
  def changeset(strategy_session, attrs) do
    strategy_session
    |> cast(attrs, [:completed])
    |> validate_required([:completed])
  end
end
