defmodule TznWeb.Admin.CalendarEventController do
  use TznWeb, :controller

  def new(conn, %{"calendar_id" => calendar_id}) do
    calendar = Tzn.Timelines.get_calendar(calendar_id)
    changeset = Tzn.Timelines.change_event(%Tzn.DB.CalendarEvent{calendar_id: calendar_id})
    render(conn, "new.html", changeset: changeset, calendar: calendar)
  end

  def create(conn, %{"calendar_event" => event_params}) do
    calendar = Tzn.Timelines.get_calendar(event_params["calendar_id"])

    case Tzn.Timelines.create_event(event_params) do
      {:ok, event} ->
        redirect(conn, to: Routes.admin_calendar_path(conn, :show, calendar))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, calendar: calendar)
    end
  end

  def edit(conn, %{"id" => id}) do
    event = Tzn.Timelines.get_event(id)
    calendar = Tzn.Timelines.get_calendar(event.calendar_id)
    changeset = Tzn.Timelines.change_event(event)
    render(conn, "edit.html", changeset: changeset, calendar: calendar, event: event)
  end

  def update(conn, %{"id" => id, "calendar_event" => event_params}) do
    event = Tzn.Timelines.get_event(id)
    calendar = Tzn.Timelines.get_calendar(event.calendar_id)

    case Tzn.Timelines.update_event(event, event_params) do
      {:ok, _event} ->
        redirect(conn, to: Routes.admin_calendar_path(conn, :show, calendar))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", calendar: calendar, changeset: changeset, event: event)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Tzn.Timelines.get_event(id)
    calendar = Tzn.Timelines.get_calendar(event.calendar_id)
    {:ok, _event} = Tzn.Timelines.delete_event(event)

    redirect(conn, to: Routes.admin_calendar_path(conn, :show, calendar))
  end
end
