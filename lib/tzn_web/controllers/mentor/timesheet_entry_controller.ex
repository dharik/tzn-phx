defmodule TznWeb.Mentor.TimesheetEntryController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Transizion.TimesheetEntry
  alias Tzn.Repo

  def index(conn, _params) do
    timesheet_entries =
      Transizion.list_timesheet_entries(conn.assigns.current_mentor)
      |> Repo.preload(:mentee)

    monthly_report = Transizion.mentor_timesheet_aggregate(conn.assigns.current_mentor.id)
    current_mentor = conn.assigns.current_mentor

    render(conn, "index.html",
      timesheet_entries: timesheet_entries,
      monthly_report: monthly_report,
      mentor: current_mentor
    )
  end

  def new(conn, params) do
    default_started_at = Timex.now() |> Timex.shift(hours: -6) |> Timex.to_naive_datetime()

    changeset =
      Transizion.change_timesheet_entry(
        %TimesheetEntry{
          started_at: default_started_at,
          ended_at: default_started_at |> Timex.shift(minutes: 30)
        },
        params
      )

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"timesheet_entry" => timesheet_entry_params}) do
    # TODO: Merge params or inject mentor_id into form
    case Transizion.create_timesheet_entry(
           timesheet_entry_params
           |> Map.put("mentor_id", conn.assigns.current_mentor.id)
         ) do
      {:ok, timesheet_entry} ->
        conn
        |> put_flash(:info, "Timesheet entry created successfully.")
        |> redirect(to: Routes.mentor_timesheet_entry_path(conn, :edit, timesheet_entry))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    timesheet_entry = Transizion.get_timesheet_entry!(id) |> Repo.preload(:mentee)
    changeset = Transizion.change_timesheet_entry(timesheet_entry)
    render(conn, "edit.html", timesheet_entry: timesheet_entry, changeset: changeset)
  end

  def update(conn, %{"id" => id, "timesheet_entry" => timesheet_entry_params}) do
    timesheet_entry = Transizion.get_timesheet_entry!(id) |> Repo.preload(:mentee)

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
