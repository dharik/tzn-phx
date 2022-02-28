defmodule TznWeb.Admin.TimesheetEntryController do
  use TznWeb, :controller

  alias Tzn.Timesheets
  alias Tzn.Repo

  def edit(conn, %{"id" => id}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id) |> Repo.preload([:mentee, :mentor])
    changeset = Timesheets.change_timesheet_entry(timesheet_entry)
    render(conn, "edit.html", timesheet_entry: timesheet_entry, changeset: changeset)
  end

  def update(conn, %{"id" => id, "timesheet_entry" => timesheet_entry_params}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id)

    case Timesheets.update_timesheet_entry(timesheet_entry, timesheet_entry_params) do
      {:ok, timesheet_entry} ->
        conn
        |> put_flash(:info, "Timesheet Entry updated successfully.")
        |> redirect(to: Routes.admin_timesheet_entry_path(conn, :edit, timesheet_entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", timesheet_entry: timesheet_entry, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id) |> Repo.preload(:mentor)
    {:ok, _mentor} = Timesheets.delete_timesheet_entry(timesheet_entry)

    conn
    |> put_flash(:info, "Timesheet Entry deleted successfully.")
    |> redirect(to: Routes.admin_mentor_path(conn, :show, timesheet_entry.mentor))
  end

end
