# This is "MenteeFile" instead of "File" to prevent namespace collision
# w/ Elixir's File module
defmodule Tzn.Files.MenteeFile do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentee_files" do
    belongs_to :mentee, Tzn.Transizion.Mentee
    field :deleted_at, :naive_datetime

    field :object_path, :string

    field :file_name, :string
    field :file_size, :integer
    field :file_content_type, :string


    belongs_to :questionnaire, Tzn.Questionnaire.Questionnaire
    belongs_to :user, Tzn.Users.User, foreign_key: :uploaded_by

    timestamps()
  end

  def upload_changeset(file, attrs) do
    file
    |> cast(attrs, [
      :object_path,
      :file_name,
      :file_size,
      :file_content_type,
      :uploaded_by,
      :mentee_id,
      :questionnaire_id
    ])
    |> validate_required([:object_path, :file_name, :file_size, :file_content_type])
    |> unique_constraint([:object_path])
    |> foreign_key_constraint(:mentee_id)
    |> foreign_key_constraint(:questionnaire_id)
  end

  def delete_changeset(file, attrs) do
    file
    |> cast(attrs, [:deleted_at])
  end
end
