defmodule Tzn.Transizion.MenteeChanges do
  use Ecto.Schema
  import Ecto.Changeset

  # TODO:
  # Period script that cleans this table up
  # We don't need more than one todo-list-change per hour
  # We can tackle that when the table starts to get large
  schema "mentee_changes" do
    belongs_to :mentee, Tzn.Transizion.Mentee
    belongs_to :user, Tzn.Users.User, foreign_key: :changed_by

    field :field, :string
    field :new_value, :string

    timestamps()
  end

  def changeset(mentee_changes, attrs) do
    mentee_changes
    |> cast(attrs, [
      :field,
      :new_value,
      :mentee_id,
      :changed_by
    ])
    |> foreign_key_constraint(:mentee_id)
    |> foreign_key_constraint(:changed_by)
  end
end
