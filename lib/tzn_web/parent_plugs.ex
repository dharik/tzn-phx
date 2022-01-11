defmodule TznWeb.ParentPlugs do
  import Plug.Conn
  import Phoenix.Controller
  require Logger
  alias TznWeb.Router.Helpers, as: Routes

  def ensure_parent_profile_and_mentees(conn, _) do
    with parent_profile <- Tzn.Profiles.get_parent(conn.assigns.current_user),
         mentees = Tzn.Profiles.list_mentees(parent_profile),
         true <- Enum.any?(mentees) do
      conn |> assign(:parent_profile, parent_profile) |> assign(:mentees, mentees)
    else
      _ ->
        Logger.error("No parent profile or mentees")
        conn |> redirect(to: Routes.entry_path(conn, :launch_app)) |> halt()
    end
  end
end
