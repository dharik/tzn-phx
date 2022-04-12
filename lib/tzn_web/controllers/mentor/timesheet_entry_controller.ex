defmodule TznWeb.Mentor.TimesheetEntryController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Timesheets
  alias Tzn.Transizion.TimesheetEntry
  alias Tzn.Repo

  def index(conn, _params) do
    timesheet_entries =
      Timesheets.list_entries(conn.assigns.current_mentor)
      |> Repo.preload(mentee: [:mentor])

    monthly_report = Timesheets.mentor_timesheet_aggregate(conn.assigns.current_mentor.id)
    current_mentor = conn.assigns.current_mentor

    render(conn, "index.html",
      timesheet_entries: timesheet_entries,
      monthly_report: monthly_report,
      mentor: current_mentor
    )
  end

  def new(conn, params) do
    default_started_at = Timex.now() |> Timex.shift(hours: -6) |> Timex.to_naive_datetime()

    mentee =
      if params["mentee_id"] do
        Transizion.get_mentee!(params["mentee_id"]) |> Repo.preload(:mentor)
      else
        nil
      end

    changeset =
      Timesheets.change_timesheet_entry(
        %TimesheetEntry{
          started_at: default_started_at,
          ended_at: default_started_at |> Timex.shift(minutes: 30)
        },
        params
      )

    render(conn, "new.html",
      changeset: changeset,
      mentee: mentee,
      last_todo_updated_at: Tzn.Transizion.most_recent_todo_list_updated_at(mentee)
    )
  end

  def create(conn, %{"timesheet_entry" => timesheet_entry_params}) do
    mentee =
      if timesheet_entry_params["mentee_id"] && timesheet_entry_params["mentee_id"] !== "" do
        Transizion.get_mentee!(timesheet_entry_params["mentee_id"]) |> Repo.preload(:hour_counts)
      else
        nil
      end

    case Timesheets.create_timesheet_entry(
           timesheet_entry_params
           |> Map.put("mentor_id", conn.assigns.current_mentor.id)
         ) do
      {:ok, _timesheet_entry} ->
        conn
        |> then(fn conn ->
          mentee = Repo.reload(mentee)
          remaining = Tzn.HourTracking.hours_remaining(mentee) |> Kernel.round()

          if Tzn.HourTracking.low_hours?(mentee) do
            put_flash(conn, :error, "Timesheet entry was saved successfully. You have #{remaining} hours remaining with #{mentee.name}.” Encourage your student to have a conversation with their parents about adding more hours if they want to work on more items with you.")
          else
            put_flash(conn, :info, "Timesheet entry created successfully.")
          end
        end)
        |> redirect(to: Routes.mentor_timesheet_entry_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html",
          changeset: changeset,
          mentee: mentee,
          last_todo_updated_at: Tzn.Transizion.most_recent_todo_list_updated_at(mentee)
        )
    end
  end

  def edit(conn, %{"id" => id}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id) |> Repo.preload(mentee: [:mentor])
    mentee = timesheet_entry.mentee
    changeset = Timesheets.change_timesheet_entry(timesheet_entry)

    render(conn, "edit.html",
      timesheet_entry: timesheet_entry,
      changeset: changeset,
      mentee: mentee,
      last_todo_updated_at: Tzn.Transizion.most_recent_todo_list_updated_at(mentee)
    )
  end

  def update(conn, %{"id" => id, "timesheet_entry" => timesheet_entry_params}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id) |> Repo.preload(mentee: [:mentor])
    mentee = timesheet_entry.mentee

    case Timesheets.update_timesheet_entry(timesheet_entry, timesheet_entry_params) do
      {:ok, timesheet_entry} ->
        conn
        |> put_flash(:info, "Timesheet entry updated successfully.")
        |> redirect(to: Routes.mentor_timesheet_entry_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          timesheet_entry: timesheet_entry,
          changeset: changeset,
          mentee: mentee,
          last_todo_updated_at: Tzn.Transizion.most_recent_todo_list_updated_at(mentee)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id)
    {:ok, _timesheet_entry} = Timesheets.delete_timesheet_entry(timesheet_entry)

    conn
    |> put_flash(:info, "Timesheet entry deleted successfully.")
    |> redirect(to: Routes.mentor_timesheet_entry_path(conn, :index))
  end
end
