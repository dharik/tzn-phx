defmodule TznWeb.Admin.UserController do
  use TznWeb, :controller

  alias Tzn.Users

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.html", users: users)
  end

  def edit(conn, %{"id" => id}) do
    user = Users.get_user!(id)
    changeset = Tzn.Users.User.pow_password_changeset(user, %{})
    render(conn, "edit.html", user: user, changeset: changeset)
  end

  def update(conn, %{"id" => id, "user" => user_params}) do
    user = Users.get_user!(id)

    case Users.User.pow_password_changeset(user, user_params) |> Tzn.Repo.update do
      {:ok, user} ->
        conn
        |> put_flash(:info, "User updated successfully.")
        |> redirect(to: Routes.admin_user_path(conn, :edit, user))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", user: user, changeset: changeset)
    end
  end

end
