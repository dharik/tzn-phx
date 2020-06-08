defmodule TznWeb.TimesheetEntryController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Transizion.TimesheetEntry

  def index(conn, _params) do
    timesheet_entries = Transizion.list_timesheet_entries()
    render(conn, "index.html", timesheet_entries: timesheet_entries)
  end

  def new(conn, _params) do
    changeset = Transizion.change_timesheet_entry(%TimesheetEntry{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"timesheet_entry" => timesheet_entry_params}) do
    case Transizion.create_timesheet_entry(timesheet_entry_params) do
      {:ok, timesheet_entry} ->
        conn
        |> put_flash(:info, "Timesheet entry created successfully.")
        |> redirect(to: Routes.timesheet_entry_path(conn, :show, timesheet_entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    timesheet_entry = Transizion.get_timesheet_entry!(id)
    render(conn, "show.html", timesheet_entry: timesheet_entry)
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
        |> redirect(to: Routes.timesheet_entry_path(conn, :show, timesheet_entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", timesheet_entry: timesheet_entry, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    timesheet_entry = Transizion.get_timesheet_entry!(id)
    {:ok, _timesheet_entry} = Transizion.delete_timesheet_entry(timesheet_entry)

    conn
    |> put_flash(:info, "Timesheet entry deleted successfully.")
    |> redirect(to: Routes.timesheet_entry_path(conn, :index))
  end
end
