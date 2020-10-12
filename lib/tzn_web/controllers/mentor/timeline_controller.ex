require IEx

defmodule TznWeb.Mentor.TimelineController do
  use TznWeb, :controller

  alias Tzn.Transizion

  def index(conn, params = %{"mentee_id" => mentee_id}) do
    mentee = Transizion.get_mentee!(mentee_id)
    events = Transizion.list_mentor_timeline_events()
       |> Enum.filter(fn event -> event.grade == mentee.grade end)
    event_markings = Transizion.mentor_timeline_event_markings(mentee)
    render(conn, "index.html", mentee: mentee, events: events, event_markings: event_markings)
  end

  def index(conn, _params) do
    events = Transizion.list_mentor_timeline_events()
    render(conn, "index.html", events: events, event_markings: %{})
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
           |> Map.put("mentor_timeline_event_id", event_id)
         ) do
      {:ok, _} ->
        conn
        |> redirect(to: Routes.mentor_timeline_path(conn, :index))

      {:error, %Ecto.Changeset{} = _changeset} ->
        conn
        |> put_flash(:info, "Error marking this task complete. Try again")
        |> redirect(to: Routes.mentor_timeline_path(conn, :index))
    end
  end
end
