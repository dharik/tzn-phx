defmodule Tzn.Users do
  alias Tzn.Repo
  alias Tzn.Users.Admin
  alias Tzn.Users.User
  import Ecto.Query

  def list_admins do
    Repo.all(Admin)
  end

  def list_users do
    User
    |> order_by(desc: :id)
    |> Repo.all()
    |> Repo.preload([:admin_profile, :mentor_profile, :mentee_profile, :parent_profile])
  end

  def get_user!(id), do: Repo.get!(User, id)

  def get_admin!(id), do: Repo.get!(Admin, id)

  def admin?(%User{admin_profile: nil}), do: false
  def admin?(%User{admin_profile: %Admin{}}), do: true
  def admin?(%User{admin_profile: %Ecto.Association.NotLoaded{} } = u) do
    u |> Ecto.assoc(:admin_profile) |> Repo.exists?()
  end

  @doc """
  Creates a admin.

  ## Examples

      iex> create_admin(%{field: value})
      {:ok, %Admin{}}

      iex> create_admin(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_admin(attrs \\ %{}) do
    %Admin{}
    |> Admin.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a admin.

  ## Examples

      iex> update_admin(admin, %{field: new_value})
      {:ok, %Admin{}}

      iex> update_admin(admin, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_admin(%Admin{} = admin, attrs) do
    admin
    |> Admin.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a admin.

  ## Examples

      iex> delete_admin(admin)
      {:ok, %Admin{}}

      iex> delete_admin(admin)
      {:error, %Ecto.Changeset{}}

  """
  def delete_admin(%Admin{} = admin) do
    Repo.delete(admin)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking admin changes.

  ## Examples

      iex> change_admin(admin)
      %Ecto.Changeset{data: %Admin{}}

  """
  def change_admin(%Admin{} = admin, attrs \\ %{}) do
    Admin.changeset(admin, attrs)
  end
end
