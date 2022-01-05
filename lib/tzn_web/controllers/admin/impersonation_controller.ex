defmodule TznWeb.Admin.ImpersonationController do
  use TznWeb, :controller
  alias Tzn.Repo

  # Admin protected
  def start(conn, %{"user_id" => user_id}) do
    user = Tzn.Users.get_user!(user_id)

    admin_profile = user
      |> Repo.preload(:admin_profile)
      |> Map.get(:admin_profile)

    if admin_profile do
      conn
        |> put_flash(:error, "You cannot impersonate another admin")
        |> redirect(to: Routes.admin_user_path(conn, :index))
    else
      conn
        |> put_session("impersonate_user_id", user_id)
        |> redirect(to: Routes.entry_path(conn, :launch_app))
    end
  end

  # Anyone can access
  def stop(conn, _) do
    conn
      |> put_session("impersonate_user_id", nil)
      |> redirect(to: Routes.admin_user_path(conn, :index))
  end
end
