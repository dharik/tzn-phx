defmodule Tzn.Transizion.MenteeWithHours do
  use Ecto.Schema

  schema "mentees_with_hours" do
    field :name, :string
    field :hours_used, :decimal
    field :hours_purchased, :decimal
    belongs_to :mentor, Tzn.Transizion.Mentor
    
    timestamps()
  end
end
