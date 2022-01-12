defmodule Tzn.Profiles do
  import Ecto.Query
  alias Tzn.Repo
  alias Tzn.Transizion.{Mentee, Parent}
  alias Tzn.Users.User

  @doc """
  Get parent profile only through a *confirmed* user account
  """
  def get_parent(%User{} = u) do
    from(p in Parent, where: p.user_id == ^u.id, limit: 1) |> Repo.one()
  end

  def list_parents(%Mentee{} = m) do
    Ecto.assoc(m, :parents) |> Repo.all()
  end

  def parent?(nil) do
    false
  end

  @doc """
  Check if there's a parent profile given a *confirmed* user account
  """
  def parent?(%User{} = u) do
    from(p in Parent, where: p.user_id == ^u.id, limit: 1) |> Repo.exists?()
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
