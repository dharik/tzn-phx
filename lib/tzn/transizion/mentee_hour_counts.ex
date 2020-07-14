defmodule Tzn.Transizion.MenteeHourCounts do
  use Ecto.Schema

  @primary_key false
  schema "mentee_hour_counts" do
    belongs_to :mentee, Tzn.Transizion.Mentee
    field :hours_used, :decimal
    field :hours_purchased, :decimal
  end
end
