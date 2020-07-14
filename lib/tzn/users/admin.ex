defmodule Tzn.Users.Admin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "admins" do
    belongs_to :user, Tzn.Users.User

    timestamps()
  end

  @doc false
  def changeset(admin, attrs) do
    admin
    |> cast(attrs, [])
    |> validate_required([])
  end
end
