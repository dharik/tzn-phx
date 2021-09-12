defmodule Tzn.CollegeList.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "college_list_questions" do
    field :display_order, :integer

    field :active, :boolean
    field :parent_answer_required, :boolean
    field :shared_with_other_lists, :boolean

    field :question, :string
    field :help, :string
    field :placeholder, :string

    timestamps()
  end

  # Admin changeset
  @doc false
  def changeset(college_list_question, attrs) do
    college_list_question
    |> cast(attrs, [:active, :question, :help, :placeholder, :display_order, :parent_answer_required,  :shared_with_other_lists])
    |> validate_required([:active, :question, :display_order, :parent_answer_required])
  end
end
