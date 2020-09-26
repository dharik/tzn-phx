require IEx

defmodule TznWeb.Mentor.TimelineController do
  use TznWeb, :controller

  alias Tzn.Transizion

  def index(conn, _params) do
    events = Transizion.mentor_timeline_events()
    event_markings = Transizion.mentor_timeline_event_markings(conn.assigns.current_mentor)
    render(conn, "index.html", events: events, event_markings: event_markings)
  end

  # Update existing event marking
  def update_or_create(conn, params = %{"event_marking_id" => event_marking_id}) do
    marking = Transizion.get_mentor_timeline_event_marking!(event_marking_id)

    case Transizion.update_mentor_timeline_event_marking(marking, params) do
      {:ok, _} ->
        conn
        |> redirect(to: Routes.mentor_timeline_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:info, "Error marking this task complete. Try again" <> changeset.errors)
        |> redirect(to: Routes.mentor_timeline_path(conn, :index))
    end
  end

  # Create a new event marking
  def update_or_create(conn, params = %{"event_id" => event_id}) do
    case Transizion.create_mentor_timeline_event_marking(
           params
           |> Map.put("mentor_id", conn.assigns.current_mentor.id)
           |> Map.put("mentor_timeline_event_id", event_id)
         ) do
      {:ok, _} ->
        conn
        |> redirect(to: Routes.mentor_timeline_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:info, "Error marking this task complete. Try again")
        |> redirect(to: Routes.mentor_timeline_path(conn, :index))
    end
  end
end
