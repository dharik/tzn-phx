defmodule TznWeb.Admin.CalendarController do
  use TznWeb, :controller

  def index(conn, _params) do
    calendars = Tzn.Timelines.list_calendars(:admin)
    render(conn, "index.html", calendars: calendars)
  end

  def new(conn, _params) do
    changeset = Tzn.Timelines.change_calendar(%Tzn.DB.Calendar{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"calendar" => calendar_params}) do
    case Tzn.Timelines.create_calendar(calendar_params) do
      {:ok, calendar} ->
        redirect(conn, to: Routes.admin_calendar_path(conn, :show, calendar))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    calendar = Tzn.Timelines.get_calendar(id)
    render(conn, "show.html", calendar: calendar)
  end

  def update(conn, %{"id" => id, "calendar" => calendar_params}) do
    calendar = Tzn.Timelines.get_calendar(id)

    case Tzn.Timelines.update_calendar(calendar, calendar_params) do
      {:ok, calendar} ->
        conn
        |> redirect(to: Routes.admin_calendar_path(conn, :show, calendar))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", calendar: calendar, changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    calendar = Tzn.Timelines.get_calendar(id)
    changeset = Tzn.Timelines.change_calendar(calendar)
    render(conn, "edit.html", changeset: changeset, calendar: calendar)
  end

  def delete(conn, %{"id" => id}) do
    calendar = Tzn.Timelines.get_calendar(id)
    {:ok, _calendar} = Tzn.Timelines.delete_calendar(calendar)

    redirect(conn, to: Routes.admin_calendar_path(conn, :index))
  end
end
