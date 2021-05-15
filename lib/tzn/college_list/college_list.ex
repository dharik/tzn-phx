defmodule Tzn.CollegeList.CollegeList do
  use Ecto.Schema
  import Ecto.Changeset

  schema "college_lists" do
    belongs_to :mentee, Tzn.Transizion.Mentee
    has_many :college_list_answers, Tzn.CollegeList.Answer

    field :state, :string
    field :access_key, :binary_id
    
    timestamps()
  end

  @doc false
  def changeset(college_list, attrs) do
    college_list
    |> cast(attrs, [:state, :access_key])
    |> ensure_access_key
    |> unique_constraint(:access_key)
    |> validate_required([:state])
    |> cast_assoc(:mentee)
  end

  defp ensure_access_key(changeset) do
    case get_change(changeset, :access_key) do
      nil -> put_change(changeset, :access_key, Ecto.UUID.bingenerate())
       "" -> put_change(changeset, :access_key, Ecto.UUID.bingenerate())
        _ -> changeset
    end
  end
end
