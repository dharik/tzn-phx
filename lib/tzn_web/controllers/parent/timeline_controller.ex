defmodule TznWeb.Parent.TimelineController do
  use TznWeb, :controller
  import TznWeb.ParentPlugs

  alias Tzn.Transizion

  plug :put_layout, "parent.html"
  plug :ensure_parent_profile_and_mentees

  def show(conn, _params) do

    mentee_id_from_session = get_session(conn, "dashboard_mentee_id")
    mentees = conn.assigns.mentees

    # The `mentee_id_from_session in mentees` check is in case an admin
    # is impersonating and the session variable wasn't cleared out
    mentee =
      if mentee_id_from_session && mentee_id_from_session in Enum.map(mentees, & &1.id) do
        Transizion.get_mentee!(mentee_id_from_session)
      else
        hd(mentees)
      end

    render(conn, "show.html", mentee: mentee)
  end

end
