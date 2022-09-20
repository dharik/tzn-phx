defmodule Tzn.DB.PodGroupToProfile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pod_groups_to_profiles" do
    belongs_to :pod_group, Tzn.DB.PodGroup
    belongs_to :school_admin, Tzn.DB.SchoolAdmin

    timestamps()
  end

  def changeset(c, params \\ %{}) do
    c
    |> cast(params, [:pod_group_id, :school_admin_id])
    |> validate_required([:pod_group_id])
  end
end
