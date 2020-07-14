defmodule Tzn.Users.User do
  use Ecto.Schema
  use Pow.Ecto.Schema

  schema "users" do
    pow_user_fields()
    has_one :admin_profile, Tzn.Users.Admin
    has_one :mentor_profile, Tzn.Transizion.Mentor
    has_one :mentee_profile, Tzn.Transizion.Mentee
    timestamps()
  end
end
