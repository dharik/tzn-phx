defmodule TznWeb.Parent.TimelineController do
  use TznWeb, :controller
  import TznWeb.ParentPlugs

  plug :put_layout, "parent.html"
  plug :ensure_parent_profile_and_mentees

  def show(conn, _params) do
    render(conn, "show.html")
  end
end
