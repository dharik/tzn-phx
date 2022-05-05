defmodule Tzn.Transizion.PodHourCounts do
  use Ecto.Schema

  @primary_key false
  schema "pod_hour_counts" do
    belongs_to :pod, Tzn.DB.Pod
    field :hours_used, :decimal
    field :hours_purchased, :decimal
    field :hours_remaining, :decimal
  end
end
