defmodule Tzn.Questionnaire.Answer do
  use Ecto.Schema
  import Ecto.Changeset

  schema "answers" do
    belongs_to :mentee, Tzn.Transizion.Mentee
    belongs_to :question, Tzn.Questionnaire.Question

    field :from_pod, :string
    field :from_parent, :string

    field :internal, :string

    timestamps()
  end

  def changeset(answer, attrs) do
    answer
    |> cast(attrs, [:from_parent, :from_pod, :internal])
    |> sanitize_pod_response()
    |> sanitize_parent_response()
    |> foreign_key_constraint(:mentee_id)
    |> foreign_key_constraint(:question_id)
  end

  def sanitize_pod_response(changeset = %{changes: %{from_pod: response}}) do
    put_change(changeset, :from_pod, HtmlSanitizeEx.basic_html(response))
  end

  def sanitize_pod_response(changeset), do: changeset

  def sanitize_parent_response(changeset = %{changes: %{from_parent: response}}) do
    put_change(changeset, :from_parent, HtmlSanitizeEx.basic_html(response))
  end

  def sanitize_parent_response(changeset), do: changeset

  def sanitize_internal_response(changeset = %{changes: %{internal: response}}) do
    put_change(changeset, :internal, HtmlSanitizeEx.basic_html(response))
  end

  def sanitize_internal_response(changeset), do: changeset
end
