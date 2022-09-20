defmodule Tzn.DB.PodGroup do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pod_groups" do
    field :name, :string
    field :admin_notes, :string
    field :expected_size, :integer

    many_to_many :pods, Tzn.DB.Pod,
      join_through: Tzn.DB.PodToPodGroup,
      join_keys: [pod_group_id: :id, pod_id: :id],
      on_replace: :delete

    many_to_many :school_admins, Tzn.DB.SchoolAdmin,
      join_through: Tzn.DB.PodGroupToProfile,
      join_keys: [pod_group_id: :id, school_admin_id: :id],
      on_replace: :delete

    timestamps()
  end

  def changeset(pod, attrs \\ %{}) do
    pod
    |> cast(attrs, [
      :name,
      :admin_notes,
      :expected_size
    ])
    |> validate_required([:name, :expected_size])
  end
end
