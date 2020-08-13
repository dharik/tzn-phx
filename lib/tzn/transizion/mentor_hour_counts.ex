defmodule Tzn.Transizion.MentorHourCounts do
  use Ecto.Schema

  @primary_key false
  schema "mentor_hour_counts" do
    belongs_to :mentor, Tzn.Transizion.Mentee
    field :year, :integer
    field :month, :integer
    field :hours, :decimal
    field :month_name, :string
  end
end
