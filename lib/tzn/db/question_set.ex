defmodule Tzn.Questionnaire.QuestionSet do
  use Ecto.Schema
  import Ecto.Changeset

  schema "question_sets" do
    many_to_many :questions, Tzn.Questionnaire.Question,
      join_through: Tzn.Questionnaire.QuestionSetQuestion

    has_many :questionnaires, Tzn.Questionnaire.Questionnaire

    field :name, :string
    field :slug, :string
  end

  def changeset(set, attrs) do
    set
    |> cast(attrs, [:name, :slug])
  end
end
