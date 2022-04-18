defmodule TznWeb.Mentor.TimesheetEntryController do
  use TznWeb, :controller

  alias Tzn.Timesheets
  alias Tzn.Transizion.TimesheetEntry
  alias Tzn.Repo

  def index(conn, _params) do
    timesheet_entries =
      Timesheets.list_entries(conn.assigns.current_mentor)
      |> Repo.preload(mentee: [:mentor])

    monthly_report = Timesheets.mentor_timesheet_aggregate(conn.assigns.current_mentor.id)

    render(conn, "index.html",
      timesheet_entries: timesheet_entries,
      monthly_report: monthly_report
    )
  end

  def new(conn, params) do
    default_started_at = Timex.now() |> Timex.shift(hours: -6) |> Timex.to_naive_datetime()

    pod = Tzn.Pod.get_pod(params["mentee_id"])
    mentee = Tzn.Mentee.get_mentee(params["mentee_id"])

    changeset =
      Timesheets.change_timesheet_entry(
        %TimesheetEntry{
          started_at: default_started_at,
          ended_at: default_started_at |> Timex.shift(minutes: 30)
        },
        params # add in the mentee id
      )

    render(conn, "new.html",
      changeset: changeset,
      last_todo_updated_at: Tzn.Pod.most_recent_todo_list_updated_at(pod),
      mentee: mentee
    )
  end

  def create(conn, %{"timesheet_entry" => timesheet_entry_params}) do
    if timesheet_entry_params["mentee_id"] && timesheet_entry_params["mentee_id"] !== "" do
      mentee =
        Tzn.Mentee.get_mentee!(timesheet_entry_params["mentee_id"]) |> Repo.preload(:hour_counts)

      case Timesheets.create_timesheet_entry(
             timesheet_entry_params
             |> Map.put("mentor_id", conn.assigns.current_mentor.id)
           ) do
        {:ok, _timesheet_entry} ->
          conn
          |> then(fn conn ->
            pod = Tzn.Pod.get_pod!(mentee.id)
            remaining = Tzn.HourTracking.hours_remaining(pod) |> Kernel.round()

            if Tzn.HourTracking.low_hours?(pod) do
              put_flash(
                conn,
                :error,
                "Timesheet entry was saved successfully. You have #{remaining} hours remaining with #{mentee.name}. Encourage your student to have a conversation with their parents about adding more hours if they want to work on more items with you."
              )
            else
              conn
            end
          end)
          |> redirect(to: Routes.mentor_timesheet_entry_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          pod = Tzn.Pod.get_pod!(mentee.id)

          render(conn, "new.html",
            changeset: changeset,
            mentee: mentee,
            last_todo_updated_at: Tzn.Pod.most_recent_todo_list_updated_at(pod)
          )
      end
    else
      case Timesheets.create_timesheet_entry(
             timesheet_entry_params
             |> Map.put("mentor_id", conn.assigns.current_mentor.id)
           ) do
        {:ok, _timesheet_entry} ->
          conn
          |> redirect(to: Routes.mentor_timesheet_entry_path(conn, :index))

        {:error, %Ecto.Changeset{} = changeset} ->
          render(conn, "new.html",
            changeset: changeset,
            mentee: nil,
            last_todo_updated_at: nil
          )
      end
    end
  end

  def edit(conn, %{"id" => id}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id) |> Repo.preload(mentee: [:mentor])
    mentee = timesheet_entry.mentee
    pod = Tzn.Pod.get_pod(mentee.id)
    changeset = Timesheets.change_timesheet_entry(timesheet_entry)

    render(conn, "edit.html",
      timesheet_entry: timesheet_entry,
      changeset: changeset,
      mentee: mentee,
      last_todo_updated_at: Tzn.Pod.most_recent_todo_list_updated_at(pod)
    )
  end

  def update(conn, %{"id" => id, "timesheet_entry" => timesheet_entry_params}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id) |> Repo.preload(mentee: [:mentor])
    mentee = timesheet_entry.mentee
    pod = Tzn.Pod.get_pod(mentee.id)

    case Timesheets.update_timesheet_entry(timesheet_entry, timesheet_entry_params) do
      {:ok, _timesheet_entry} ->
        conn
        |> redirect(to: Routes.mentor_timesheet_entry_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html",
          timesheet_entry: timesheet_entry,
          changeset: changeset,
          mentee: mentee,
          last_todo_updated_at: Tzn.Pod.most_recent_todo_list_updated_at(pod)
        )
    end
  end

  def delete(conn, %{"id" => id}) do
    timesheet_entry = Timesheets.get_timesheet_entry!(id)
    {:ok, _timesheet_entry} = Timesheets.delete_timesheet_entry(timesheet_entry)

    conn
    |> redirect(to: Routes.mentor_timesheet_entry_path(conn, :index))
  end
end
