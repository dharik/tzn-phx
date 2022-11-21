defmodule Tzn.DB.QuestionnaireSnapshot do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questionnaire_snapshots" do
    belongs_to :questionnaire, Tzn.Questionnaire.Questionnaire
    field :state, :string
    field :snapshot_data, :map
    timestamps()
  end

  def changeset(q, attrs \\ %{}) do
    q
    |> cast(attrs, [:state, :snapshot_data, :questionnaire_id])
    |> validate_required([:state, :snapshot_data, :questionnaire_id])
    |> validate_inclusion(:state, [
      "needs_info",
      "ready_for_specialist",
      "specialist",
      "designer",
      "complete"
    ])
    |> foreign_key_constraint(:questionnaire_id)
  end
end
