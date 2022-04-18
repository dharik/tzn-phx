defmodule TznWeb.Parent.WorklogController do
  use TznWeb, :controller
  import TznWeb.ParentPlugs

  plug :ensure_parent_profile_and_mentees
  plug :load_mentee

  plug :put_layout, "parent.html"
  alias Tzn.Transizion

  def show(conn, _params) do
    mentee = conn.assigns.mentee
    mentor = Transizion.get_mentor(mentee)
    timesheet_entries = Tzn.Timesheets.list_entries(mentee)
    hour_counts = Transizion.get_hour_counts(mentee)
    hours_used = hour_counts.hours_used |> Decimal.round(1)

    conn
    |> render("show.html",
      hours_used: hours_used,
      timesheet_entries: timesheet_entries,
      mentor: mentor
    )
  end
end
