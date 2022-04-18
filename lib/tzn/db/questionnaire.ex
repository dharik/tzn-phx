defmodule Tzn.Questionnaire.Questionnaire do
  use Ecto.Schema
  import Ecto.Changeset

  schema "questionnaires" do
    belongs_to :mentee, Tzn.Transizion.Mentee
    belongs_to :question_set, Tzn.Questionnaire.QuestionSet

    field :state, :string
    field :access_key, :binary_id

    field :access_key_used_at, :naive_datetime
    field :parent_email_sent_at, :naive_datetime

    has_many :files, Tzn.Files.MenteeFile

    timestamps()
  end

  def changeset(q, attrs \\ %{}) do
    q
    |> cast(attrs, [:state, :access_key, :mentee_id, :question_set_id, :access_key_used_at, :parent_email_sent_at])
    |> ensure_access_key
    |> validate_required([:state, :access_key])
    |> validate_inclusion(:state, [
      "needs_info",
      "ready_for_specialist",
      "specialist",
      "designer",
      "complete"
    ])
    |> unique_constraint(:access_key)
    |> assoc_constraint(:mentee)
    |> assoc_constraint(:question_set)
  end

  defp ensure_access_key(changeset) do
    case get_field(changeset, :access_key) do
      nil -> put_change(changeset, :access_key, Ecto.UUID.generate())
      "" -> put_change(changeset, :access_key, Ecto.UUID.generate())
      _ -> changeset
    end
  end
end
