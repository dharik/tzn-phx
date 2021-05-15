defmodule Tzn.CollegeList.CollegeListQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "college_list_questions" do
    field :active, :boolean
    field :question, :string
    field :display_order, :integer
    field :parent_answer_required, :boolean
    
    timestamps()
  end

  # Admin changeset
  @doc false
  def changeset(college_list_question, attrs) do
    college_list_question
    |> cast(attrs, [:active, :question, :display_order, :parent_answer_required])
    |> validate_required([:active, :question, :display_order, :parent_answer_required])
  end
end
