defmodule Tzn.Questionnaire.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "answers" do
    belongs_to :mentee, Tzn.Transizion.Mentee
    belongs_to :question, Tzn.Questionnaire.Question

    field :from_pod, :string
    field :from_parent, :string

    timestamps()
  end

  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:from_parent, :from_pod])
    |> foreign_key_constraint(:mentee_id)
    |> foreign_key_constraint(:question_id)
  end
end
