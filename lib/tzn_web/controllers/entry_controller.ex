defmodule TznWeb.EntryController do
  use TznWeb, :controller
  import TznWeb.AdminPlugs
  import TznWeb.MentorPlugs

  plug :load_admin_profile
  plug :load_mentor_profile

  def launch_app(conn, _) do
    parent_profile = Tzn.Profiles.get_parent(conn.assigns.current_user)
    school_admin_profile = Tzn.Profiles.get_school_admin(conn.assigns.current_user)

    available_profiles = [
      conn.assigns[:current_admin],
      conn.assigns[:current_mentor],
      parent_profile,
      school_admin_profile
    ] |> Enum.reject(&is_nil/1)
    cond do
      Enum.count(available_profiles) > 1 ->
        render(conn, "choose_profile.html", parent_profile: parent_profile, school_admin_profile: school_admin_profile)
      conn.assigns.current_admin ->
        conn |> redirect(to: Routes.admin_mentor_path(conn, :index))
      conn.assigns.current_mentor ->
        conn |> redirect(to: Routes.mentor_pod_path(conn, :index))
      Tzn.Profiles.parent?(conn.assigns.current_user) ->
        conn |> redirect(to: Routes.parent_dashboard_path(conn, :show))
      school_admin_profile ->
        conn |> redirect(to: Routes.entry_path(conn, :launch_school_admin_app))
      true ->
        render(conn, "no_profile.html")
    end
  end

  def launch_school_admin_app(conn, _) do
    conn
    |> put_layout("school_admin.html")
    |> render("school_admin.html")
  end


end
