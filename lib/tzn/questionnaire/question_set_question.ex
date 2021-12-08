defmodule Tzn.Questionnaire.QuestionSetQuestion do
  use Ecto.Schema
  import Ecto.Changeset

  schema "question_sets_questions" do
    belongs_to :question, Tzn.Questionnaire.Question
    belongs_to :question_set, Tzn.Questionnaire.QuestionSet

    field :display_order, :integer
  end

  def changeset(qsq, attrs) do
    qsq |> cast(attrs, [:display_order])
  end
end
