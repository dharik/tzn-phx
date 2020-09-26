defmodule TznWeb.AdminPlugs do
  import Plug.Conn
  alias Tzn.Repo
  alias Tzn.Transizion

  def load_admin_profile(conn, _) do
    admin_profile =
      conn.assigns.current_user
      |> Repo.preload(:admin_profile)
      |> Map.get(:admin_profile)

    conn |> assign(:current_admin, admin_profile)
  end
end
