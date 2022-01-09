defmodule Tzn.Profiles do
  import Ecto.Query
  alias Tzn.Repo
  alias Tzn.Transizion.{Mentee, Mentor, Parent}
  alias Tzn.Users.User

  def get_parent(%User{email_confirmed_at: nil}) do
    nil
  end

  def get_parent(%User{email: email}) do
    get_parent_by_email(email)
  end

  @doc """
  Since an email can be unconfirmed, it's safer to keep this private
  and use get_parent(%User). Eventually I think we'll have dedicated
  parent profiles in the DB so we wouldn't look up by email, we'd look
  up by foriegn keys
  """
  defp get_parent_by_email(email) do
    mentees =
      from(m in Mentee, where: m.parent1_email == ^email or m.parent2_email == ^email) |> Repo.exists?()

    p1_names =
      from(m in Mentee, where: m.parent1_email == ^email, select: m.parent1_name) |> Repo.all()

    p2_names =
      from(m in Mentee, where: m.parent2_email == ^email, select: m.parent2_name) |> Repo.all()

    if mentees do
      # Have to pick the best name because they can vary
      name = (p1_names ++ p2_names) |> Enum.reject(&is_nil/1) |> List.first()

      %Parent{name: name, email: email}
    else
      nil
    end
  end

  def list_parents(%Mentee{} = m) do
    cond do
      m.parent1_email &&
          m.parent2_email ->
        [
          %Parent{email: m.parent1_email, name: m.parent1_name},
          %Parent{email: m.parent2_email, name: m.parent2_name}
        ]

      m.parent1_email ->
        [%Parent{email: m.parent1_email, name: m.parent1_name}]

      m.parent2_email ->
        [%Parent{email: m.parent2_email, name: m.parent2_name}]

      true ->
        []
    end
  end

  def parent?(nil) do
    false
  end

  def parent?(%User{email_confirmed_at: nil}) do
    false
  end

  def parent?(%User{email: email}) do
    !is_nil(get_parent_by_email(email))
  end







  def mentee?(%User{email_confirmed_at: nil}) do
    false
  end

  def mentee?(nil) do
    false
  end

  def mentee?(%User{email: email}) do
    mentee?(email)
  end

  def mentee?(email) do
    q = from(m in Mentee, where: m.email == ^email)
    Repo.exists?(q)
  end

  def list_mentees(%Parent{email: email}) do
    q =
      from(m in Mentee,
        where: m.parent1_email == ^email or m.parent2_email == ^email
      )

    Repo.all(q)
  end

  def list_mentees(nil) do
    []
  end
end
