defmodule Tzn.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  use Pow.Extension.Ecto.Schema,
    extensions: [PowEmailConfirmation, PowResetPassword]

  schema "users" do
    has_one :admin_profile, Tzn.Users.Admin
    has_one :mentor_profile, Tzn.Transizion.Mentor
    has_one :mentee_profile, Tzn.Transizion.Mentee
    has_one :parent_profile, Tzn.Transizion.Parent

    timestamps()
    pow_user_fields()
  end

  def changeset(user_or_changeset, attrs) do
    user_or_changeset
    |> pow_changeset(attrs)
    |> pow_extension_changeset(attrs)
  end
end
