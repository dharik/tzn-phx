defmodule Tzn.DB.PodFlag do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pod_flags" do
    belongs_to :pod, Tzn.DB.Pod

    field :description, :string
    field :status, :string
    field :parent_can_read, :boolean, default: false
    field :school_admin_can_read, :boolean, default: false

    timestamps()
  end

  def changeset(flag, attrs) do
    flag
    |> cast(attrs, [
      :description,
      :status,
      :pod_id,
      :parent_can_read,
      :school_admin_can_read
    ])
    |> validate_required([:pod_id, :status, :description])
    |> validate_length(:description, min: 3)
    |> validate_inclusion(:status, ["open", "resolved"])
    |> foreign_key_constraint(:pod_id)
  end
end
