defmodule TznWeb.Mentor.TimelineController do
  use TznWeb, :controller

  alias Tzn.Transizion

  def index(conn, %{"mentee_id" => mentee_id}) do
    mentee = Tzn.Mentee.get_mentee!(mentee_id)
    events = Transizion.list_mentor_timeline_events()
      |> Enum.filter(fn event -> event.grade == mentee.grade end)
    event_markings = Transizion.mentor_timeline_event_markings(mentee)
    render(conn, "index.html", mentee: mentee, events: events, event_markings: event_markings)
  end

  def index(conn, _params) do
    events = Transizion.list_mentor_timeline_events()
    render(conn, "no_mentee_index.html", events: events)
  end
end
