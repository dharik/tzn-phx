defmodule Tzn.DB.Version do
  use Ecto.Schema
  import Ecto.Changeset

  schema "versions" do
    # The patch in Erlang External Term Format
    field :patch, ExAudit.Type.Patch

    # supports UUID and other types as well
    field :entity_id, :integer

    # name of the table the entity is in
    field :entity_schema, ExAudit.Type.Schema

    # type of the action that has happened to the entity (created, updated, deleted)
    field :action, ExAudit.Type.Action

    # when has this happened
    field :recorded_at, :utc_datetime_usec

    # was this change part of a rollback?
    field :rollback, :boolean, default: false

    # custom fields
    belongs_to :user, Tzn.Users.User
  end

  def changeset(struct, params \\ %{}) do
    struct
    |> cast(params, [:patch, :entity_id, :entity_schema, :action, :recorded_at, :rollback])
    |> cast(params, [:user_id]) # custom fields
  end
end
