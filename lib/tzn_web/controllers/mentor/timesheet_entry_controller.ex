defmodule TznWeb.Mentor.TimesheetEntryController do
  use TznWeb, :controller

  import TznWeb.MentorPlugs
  plug :load_my_mentees
  plug :load_mentor_profile
  
  alias Tzn.Transizion
  alias Tzn.Transizion.TimesheetEntry
  alias Tzn.Repo
  
  def index(conn, _params) do
    import Ecto.Query
    timesheet_entries = Transizion.list_timesheet_entries(%{mentor: conn.assigns.current_user}) |> Repo.preload(:mentee)
    monthly_report = Transizion.mentor_timesheet_aggregate(conn.assigns.current_mentor.id)
    render(conn, "index.html", timesheet_entries: timesheet_entries, monthly_report: monthly_report)
  end

  def new(conn, _params) do
    changeset = Transizion.change_timesheet_entry(%TimesheetEntry{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"timesheet_entry" => timesheet_entry_params}) do
    # TODO: Merge params or inject mentor_id into form
    case Transizion.create_timesheet_entry(timesheet_entry_params |> Map.put("mentor_id", conn.assigns.current_user.id)) do
      {:ok, timesheet_entry} ->
        conn
        |> put_flash(:info, "Timesheet entry created successfully.")
        |> redirect(to: Routes.mentor_timesheet_entry_path(conn, :edit, timesheet_entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    timesheet_entry = Transizion.get_timesheet_entry!(id)
    changeset = Transizion.change_timesheet_entry(timesheet_entry)
    render(conn, "edit.html", timesheet_entry: timesheet_entry, changeset: changeset)
  end

  def update(conn, %{"id" => id, "timesheet_entry" => timesheet_entry_params}) do
    timesheet_entry = Transizion.get_timesheet_entry!(id)

    case Transizion.update_timesheet_entry(timesheet_entry, timesheet_entry_params) do
      {:ok, timesheet_entry} ->
        conn
        |> put_flash(:info, "Timesheet entry updated successfully.")
        |> redirect(to: Routes.mentor_timesheet_entry_path(conn, :edit, timesheet_entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", timesheet_entry: timesheet_entry, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    timesheet_entry = Transizion.get_timesheet_entry!(id)
    {:ok, _timesheet_entry} = Transizion.delete_timesheet_entry(timesheet_entry)

    conn
    |> put_flash(:info, "Timesheet entry deleted successfully.")
    |> redirect(to: Routes.mentor_timesheet_entry_path(conn, :index))
  end
end
