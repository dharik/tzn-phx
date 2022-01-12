defmodule Tzn.Transizion.Parent do
  use Ecto.Schema

  @primary_key false
  schema "parents" do
    belongs_to :mentee, Tzn.Transizion.Mentee
    belongs_to :user, Tzn.Users.User

    field :name, :string
    field :email, :string
  end
end
