defmodule TznWeb.Parent.WorklogController do
  use TznWeb, :controller
  import TznWeb.ParentPlugs

  plug :ensure_parent_profile_and_mentees
  plug :put_layout, "parent.html"

  def show(conn, _params) do
    conn
    |> render("show.html",
      hours_used: conn.assigns.pod.hour_counts.hours_used,
      timesheet_entries: conn.assigns.pod.timesheet_entries,
      mentor: conn.assigns.pod.mentor
    )
  end
end
