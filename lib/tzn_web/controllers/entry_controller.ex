defmodule TznWeb.EntryController do
  use TznWeb, :controller
  import TznWeb.AdminPlugs
  import TznWeb.MentorPlugs

  plug :load_admin_profile
  plug :load_mentor_profile

  def launch_app(conn, _) do
    cond do
      conn.assigns.current_admin ->
        conn |> redirect(to: Routes.admin_user_path(conn, :index))
      conn.assigns.current_mentor ->
        conn |> redirect(to: Routes.mentor_mentee_path(conn, :index))
      true ->
        conn |> halt
    end
  end

end
