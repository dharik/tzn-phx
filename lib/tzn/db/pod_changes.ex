defmodule Tzn.DB.PodChanges do
  use Ecto.Schema
  import Ecto.Changeset

  schema "pod_changes" do
    belongs_to :pod, Tzn.DB.Pod
    belongs_to :user, Tzn.Users.User, foreign_key: :changed_by

    field :field, :string
    field :new_value, :string
    field :old_value, :string

    timestamps()
  end

  def changeset(pod_changes, attrs) do
    pod_changes
    |> cast(attrs, [
      :field,
      :new_value,
      :old_value,
      :pod_id,
      :changed_by
    ])
    |> foreign_key_constraint(:pod_id)
    |> foreign_key_constraint(:changed_by)
  end
end
