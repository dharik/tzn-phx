defmodule TznWeb.Parent.TimelineController do
  use TznWeb, :controller
  import TznWeb.ParentPlugs

  alias Tzn.Transizion

  plug :put_layout, "parent.html"
  plug :ensure_parent_profile_and_mentees
  plug :load_mentee

  def show(conn, _params) do
    mentee = conn.assigns.mentee

    render(conn, "show.html", mentee: mentee)
  end

end
