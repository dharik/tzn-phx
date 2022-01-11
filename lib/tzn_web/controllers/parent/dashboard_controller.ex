defmodule TznWeb.Parent.DashboardController do
  use TznWeb, :controller
  import TznWeb.ParentPlugs

  plug :ensure_parent_profile_and_mentees
  plug :put_layout, "parent.html"
  alias Tzn.Transizion

  def show(conn, %{"mentee" => mentee_id}) do
    mentee = Transizion.get_mentee!(mentee_id)

    unless mentee in conn.assigns.mentees do
      raise Tzn.Policy.UnauthorizedError
    end

    conn
    |> put_session("dashboard_mentee_id", mentee.id)
    |> redirect(to: Routes.parent_dashboard_path(conn, :show))
  end

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

    mentor = Transizion.get_mentor(mentee)
    timesheet_entries = Transizion.list_timesheet_entries(mentee)
    hour_counts = Transizion.get_hour_counts(mentee)
    hours_used = hour_counts.hours_used |> Decimal.round(1)

    conn
    |> render("show.html",
      mentee: mentee,
      hours_used: hours_used,
      timesheet_entries: timesheet_entries,
      mentor: mentor
    )
  end
end
