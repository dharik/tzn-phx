defmodule Tzn.DB.SchoolAdmin do
  use Ecto.Schema
  import Ecto.Changeset

  schema "school_admins" do
    belongs_to :user, Tzn.Users.User

    field :name, :string
    field :nick_name, :string
    field :pronouns, :string
    field :email, :string

    many_to_many :pod_groups, Tzn.DB.PodGroup,
      join_through: Tzn.DB.PodGroupToProfile,
      join_keys: [school_admin_id: :id, pod_group_id: :id]

    timestamps()
  end

  @doc false
  def changeset(record, attrs) do
    record
    |> cast(attrs, [
      :nick_name,
      :pronouns,
      :name,
      :email
    ])
    |> validate_required([:name, :email])
  end
end
