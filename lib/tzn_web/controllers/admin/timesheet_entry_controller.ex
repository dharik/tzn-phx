defmodule TznWeb.Admin.TimesheetEntryController do
  use TznWeb, :controller

  alias Tzn.Timesheets

  def edit(conn, %{"id" => id}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id)
    mentor = Tzn.Transizion.get_mentor(timesheet_entry.mentor_id)
    pod = Tzn.Pods.get_pod(timesheet_entry.pod_id)
    pods = Tzn.Pods.list_pods(mentor)
    changeset = Timesheets.change_timesheet_entry(timesheet_entry)

    render(conn, "edit.html",
      timesheet_entry: timesheet_entry,
      changeset: changeset,
      pods: pods,
      pod: pod,
      mentor: mentor
    )
  end

  def update(conn, %{"id" => id, "timesheet_entry" => timesheet_entry_params}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id)
    mentor = Tzn.Transizion.get_mentor(timesheet_entry.mentor_id)
    pod = Tzn.Pods.get_pod(timesheet_entry.pod_id)
    pods = Tzn.Pods.list_pods(mentor)

    case Timesheets.update_timesheet_entry(timesheet_entry, timesheet_entry_params) do
      {:ok, timesheet_entry} ->
        conn
        |> redirect(to: Routes.admin_timesheet_entry_path(conn, :edit, timesheet_entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          timesheet_entry: timesheet_entry,
          changeset: changeset,
          pods: pods,
          pod: pod,
          mentor: mentor
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id)
    {:ok, _mentor} = Timesheets.delete_timesheet_entry(timesheet_entry)

    conn
    |> redirect(to: Routes.admin_mentor_path(conn, :show, timesheet_entry.mentor))
  end
end
