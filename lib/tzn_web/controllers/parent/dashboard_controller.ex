defmodule TznWeb.Parent.DashboardController do
  use TznWeb, :controller
  plug :put_layout, "parent.html"
  alias Tzn.Transizion

  def show(conn, %{"mentee" => mentee_id}) do
    mentee = Transizion.get_mentee!(mentee_id)
    parent_profile = Tzn.Profiles.get_parent(conn.assigns.current_user)
    mentees = Tzn.Profiles.list_mentees(parent_profile)

    unless mentee in mentees do
      raise Tzn.Policy.UnauthorizedError
    end

    conn
    |> put_session("dashboard_mentee_id", mentee.id)
    |> redirect(to: Routes.parent_dashboard_path(conn, :show))
  end

  def show(conn, _params) do
    mentee_id_from_session = get_session(conn, "dashboard_mentee_id")
    parent_profile = Tzn.Profiles.get_parent(conn.assigns.current_user)
    mentees = Tzn.Profiles.list_mentees(parent_profile)

    mentee =
      if mentee_id_from_session do
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
      mentor: mentor,
      mentees: mentees
    )
  end
end
