defmodule TznWeb.Parent.DashboardController do
  use TznWeb, :controller
  import TznWeb.ParentPlugs

  plug :ensure_parent_profile_and_mentees
  plug :load_questionnaires

  plug :put_layout, "parent.html"

  def show(conn, _params) do
    conn
    |> render("show.html")
  end
end
