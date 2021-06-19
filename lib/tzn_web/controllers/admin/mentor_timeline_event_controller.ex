defmodule TznWeb.Admin.MentorTimelineEventController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Transizion.MentorTimelineEvent

  def index(conn, %{"grade" => grade}) do
    events = Transizion.list_mentor_timeline_events()
    render(conn, "index.html", events: Enum.filter(events, fn e -> e.grade == grade end))
  end

  def index(conn, _params) do
    events = Transizion.list_mentor_timeline_events()
    render(conn, "index.html", events: events)
  end

  def new(conn, _params) do
    changeset = Transizion.change_mentor_timeline_event(%MentorTimelineEvent{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mentor_timeline_event" => event_params}) do
    case Transizion.create_mentor_timeline_event(event_params) do
      {:ok, _} -> 
          conn 
            |> put_flash(:info, "Timeline event created successfully.") 
            |> redirect(to: Routes.admin_mentor_timeline_event_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    mentor_timeline_event = Transizion.get_mentor_timeline_event!(id)
    changeset = Transizion.change_mentor_timeline_event(mentor_timeline_event)
    render(conn, "edit.html", event: mentor_timeline_event, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mentor_timeline_event" => mentor_timeline_event_params}) do
    mentor_timeline_event = Transizion.get_mentor_timeline_event!(id)

    case Transizion.update_mentor_timeline_event(mentor_timeline_event, mentor_timeline_event_params) do
      {:ok, mentor_timeline_event} ->
        conn
        |> put_flash(:info, "Timeline Event updated successfully.")
        |> redirect(to: Routes.admin_mentor_timeline_event_path(conn, :edit, mentor_timeline_event))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", event: mentor_timeline_event, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    event = Transizion.get_mentor_timeline_event!(id)
    {:ok, _} = Transizion.delete_mentor_timeline_event(event)

    conn
    |> put_flash(:info, "Timeline event deleted successfully.")
    |> redirect(to: Routes.admin_mentor_timeline_event_path(conn, :index))
  end
end