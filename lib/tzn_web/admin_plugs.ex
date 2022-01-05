defmodule TznWeb.AdminPlugs do
  import Plug.Conn
  alias Tzn.Repo

  def load_admin_profile(conn, _) do
    admin_profile =
      conn.assigns.current_user
      |> Repo.preload(:admin_profile)
      |> Map.get(:admin_profile)

    conn |> assign(:current_admin, admin_profile)
  end

  def ensure_admin_profile(conn, _) do
    if conn.assigns.current_admin do
      conn
    else
      conn |> halt
    end
  end

  def override_current_user_for_impersonation(conn, _) do
    user_id = conn |> get_session("impersonate_user_id")

    if user_id && conn.assigns[:current_user] do
      u = Tzn.Users.get_user!(user_id)

      conn
      |> Pow.Plug.assign_current_user(u, Pow.Plug.fetch_config(conn))
      |> assign(:impersonating, true)
    else
      conn
      |> assign(:impersonating, false)
      |> put_session("impersonate_user_id", nil)
    end
  end
end
