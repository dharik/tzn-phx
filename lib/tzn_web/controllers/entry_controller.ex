defmodule TznWeb.EntryController do
  use TznWeb, :controller
  import TznWeb.AdminPlugs
  import TznWeb.MentorPlugs

  plug :load_admin_profile
  plug :load_mentor_profile

  def launch_app(conn, _) do
    parent_profile = Tzn.Profiles.get_parent(conn.assigns.current_user)

    available_profiles = [
      conn.assigns[:current_admin],
      conn.assigns[:current_mentor],
      parent_profile
    ] |> Enum.reject(&is_nil/1)
    cond do
      Enum.count(available_profiles) > 1 ->
        render(conn, "choose_profile.html", parent_profile: parent_profile)
      conn.assigns.current_admin ->
        conn |> redirect(to: Routes.admin_mentor_path(conn, :index))
      conn.assigns.current_mentor ->
        conn |> redirect(to: Routes.mentor_mentee_path(conn, :index))
      Tzn.Profiles.parent?(conn.assigns.current_user) ->
        conn |> redirect(to: Routes.parent_dashboard_path(conn, :show))
      true ->
        render(conn, "no_profile.html")
    end
  end

end
