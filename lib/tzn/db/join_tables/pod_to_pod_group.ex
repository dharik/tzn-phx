defmodule Tzn.DB.PodToPodGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pods_to_pod_groups" do
    belongs_to :pod_group, Tzn.DB.PodGroup
    belongs_to :pod, Tzn.DB.Pod

    timestamps()
  end

  def changeset(c, params \\ %{}) do
    c
    |> cast(params, [:pod_group_id, :pod_id])
    |> validate_required([:pod_group_id, :pod_id])
  end
end
