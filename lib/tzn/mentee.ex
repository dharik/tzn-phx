defmodule Tzn.Mentee do
  alias Tzn.Repo
  alias Tzn.Transizion.{Mentee, MenteeChanges, Mentor}
  alias Tzn.Users.User

  import Ecto.Query

  def get_mentee(nil), do: nil
  def get_mentee!(id), do: Repo.get!(Mentee, id)
  def get_mentee(id), do: Repo.get(Mentee, id)
  def get_mentee_by_email(email), do: Repo.get_by(Mentee, email: email)

  def delete_mentee(%Mentee{} = mentee) do
    Repo.delete(mentee)
  end

  def change_mentee(%Mentee{} = mentee, attrs \\ %{}) do
    Mentee.changeset(mentee, attrs)
  end

  def create_mentee(attrs \\ %{}) do
    %Mentee{}
    |> Mentee.changeset(attrs)
    |> Repo.insert()
  end

  def admin_change_mentee(%Mentee{} = mentee, attrs \\ %{}) do
    Mentee.admin_changeset(mentee, attrs)
  end

  def admin_create_mentee(attrs \\ %{}) do
    %Mentee{}
    |> Mentee.admin_changeset(attrs)
    |> Repo.insert()
  end

  def update_mentee(%Mentee{} = mentee, attrs, %User{} = user) do
    mentee_changeset = Mentee.changeset(mentee, attrs)

    if mentee_changeset.valid? do
      update_and_track_mentee_changes(mentee, mentee_changeset, user)
    else
      Ecto.Changeset.apply_action(mentee_changeset, :update)
    end
  end

  def admin_update_mentee(%Mentee{} = mentee, attrs, %User{} = user) do
    mentee_changeset = Mentee.admin_changeset(mentee, attrs)

    if mentee_changeset.valid? do
      update_and_track_mentee_changes(mentee, mentee_changeset, user)
    else
      Ecto.Changeset.apply_action(mentee_changeset, :update)
    end
  end

  def update_and_track_mentee_changes(%Mentee{} = mentee, changeset, %User{} = user) do
    Repo.transaction(fn ->
      mentee_result = changeset |> Repo.update!()

      Map.to_list(changeset.changes)
      |> Enum.filter(fn {field, _} ->
        field in [
          :parent_todo_notes,
          :mentor_todo_notes,
          :mentee_todo_notes,
          :grade,
          :mentor_rate
        ]
      end)
      |> Enum.each(fn {field, value} ->
        Repo.insert!(
          MenteeChanges.changeset(%MenteeChanges{}, %{
            mentee_id: mentee.id,
            changed_by: user.id,
            field: Atom.to_string(field),
            new_value: String.Chars.to_string(value)
          })
        )
      end)

      mentee_result
    end)
  end

  def list_mentees do
    Mentee |> order_by(asc: :archived, asc: :name) |> Repo.all()
  end

  def list_mentees(%Mentor{} = mentor) do
    Repo.all(
      from(m in Mentee, where: m.mentor_id == ^mentor.id, order_by: [asc: m.archived, desc: m.id])
    )
  end

  def list_pods(%Mentee{} = mentee) do
    Repo.all(from(p in Tzn.Pod, where: p.id == ^mentee.id))
  end

  def name(%{}, :informal) do
    # nick name || full name
  end

  def name(%{}, :formal) do
    # full name
  end
end
