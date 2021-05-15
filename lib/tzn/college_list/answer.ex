defmodule Tzn.CollegeList.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "college_list_answers" do
    belongs_to :college_list, Tzn.CollegeList.CollegeList
    belongs_to :college_list_question, Tzn.CollegeList.Question

    field :from_pod, :string
    field :from_parent, :string

    timestamps()
  end

  # Parent changeset
  def parent_changeset(college_list_answer, attrs) do
    college_list_answer
    |> cast(attrs, [:from_parent])
    |> validate_required([:college_list, :college_list_question])
  end

  # Admin/mentor changeset
  def mentor_changeset(college_list_answer, attrs) do
    college_list_answer
    |> cast(attrs, [:from_pod])
    |> validate_required([:college_list, :college_list_question])
  end
end
