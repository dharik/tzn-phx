require IEx

defmodule TznWeb.Mentor.TimelineController do
  use TznWeb, :controller

  import TznWeb.MentorPlugs
  plug :load_my_mentees
  plug :load_mentor_profile

  alias Tzn.Transizion
  alias Tzn.Transizion.Timeline
  alias Tzn.Transizion.TimelineEvent
  alias Tzn.Transizion.TimelineEventMarking
  alias Tzn.Repo

  def index(conn, _params) do
    events = Transizion.mentor_timeline_events()
    event_markings = Transizion.mentor_timeline_event_markings(conn.assigns.current_mentor)
    render(conn, "index.html", events: events, event_markings: event_markings)
  end

  def update(conn, %{"id" => id}) do
    # Update existing

  end

  def update(conn, %{"event_id" => event_id, "id" => nil}) do
    # Create new marking
    case Transizion.create_mentor_timeline_event_marking(%{
          mentor_timeline_event_id: event_id,
          mentor_id: conn.assigns.current_mentor.id,
          completed: true
        }) do
    {:ok, _} ->
      conn
      |> redirect(to: Routes.mentor_timeline_path(conn, :index))

    {:error, %Ecto.Changeset{} = changeset} ->
      conn
      |> put_flash(:info, "Error marking this task complete. Try again")
      |> redirect(to: Routes.mentor_timeline_path(conn, :index))
    end
  end



  def create(conn, %{"event_id" => event_id}) do
    case Transizion.create_mentor_timeline_event_marking(%{
           mentor_timeline_event_id: event_id,
           mentor_id: conn.assigns.current_mentor.id,
           completed: true
         }) do
      {:ok, _} ->
        conn
        |> redirect(to: Routes.mentor_timeline_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        conn
        |> put_flash(:info, "Error marking this task complete. Try again")
        |> redirect(to: Routes.mentor_timeline_path(conn, :index))
    end
  end

  def delete(conn, %{"id" => id}) do
    marking = Transizion.get_mentor_timeline_event_marking!(id, conn.assigns.current_mentor.id)
    {:ok, _} = Transizion.delete_mentor_timeline_event_marking(marking)

    conn
    |> redirect(to: Routes.mentor_timeline_path(conn, :index))
  end
end
