defmodule Tzn.Questionnaire.Question do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questions" do
    field :question, :string
    field :placeholder, :string # Unused
    field :parent_answer_required, :boolean

    many_to_many :question_sets, Tzn.Questionnaire.QuestionSet,
      join_through: Tzn.Questionnaire.QuestionSetQuestion,
      join_defaults: :set_display_order,
      unique: true,
      on_replace: :delete

    timestamps()
  end

  def changeset(question, attrs) do
    question
    |> cast(attrs, [:question, :placeholder, :parent_answer_required])
    |> validate_required([:question, :parent_answer_required])
  end

  def set_display_order(question_set_question, _question) do
    %{question_set_question | display_order: 0}
  end
end
