defmodule TznWeb.Mentor.TimelineEventMarkingController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Transizion.MentorTimelineEventMarking
  alias Tzn.Repo

  def new(conn, %{"event_id" => event_id, "mentee_id" => mentee_id}) do
    changeset =
      Transizion.change_mentor_timeline_event_marking(%MentorTimelineEventMarking{
        mentor_timeline_event_id: event_id,
        mentee_id: mentee_id
      })

    mentee = Tzn.Mentee.get_mentee!(mentee_id)
    event = Transizion.get_mentor_timeline_event!(event_id)
    render(conn, "new.html", changeset: changeset, mentee: mentee, event: event)
  end

  def create(conn, %{"mentor_timeline_event_marking" => marking_params}) do
    mentee = Tzn.Mentee.get_mentee!(marking_params |> Map.get("mentee_id"))

    event =
      Transizion.get_mentor_timeline_event!(marking_params |> Map.get("mentor_timeline_event_id"))

    case Transizion.create_mentor_timeline_event_marking(marking_params) do
      {:ok, marking} ->
        conn
        |> redirect(
          to:
            Routes.mentor_timeline_path(conn, :index, mentee_id: marking.mentee_id) <>
              "#event-#{marking.mentor_timeline_event_id}"
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, mentee: mentee, event: event)
    end
  end

  def edit(conn, %{"id" => marking_id}) do
    marking =
      Transizion.get_mentor_timeline_event_marking!(marking_id)
      |> Repo.preload([:mentee, :mentor_timeline_event])

    mentee = marking.mentee
    event = marking.mentor_timeline_event
    changeset = Transizion.change_mentor_timeline_event_marking(marking)
    render(conn, "edit.html", changeset: changeset, marking: marking, mentee: mentee, event: event)
  end

  def update(conn, %{"id" => marking_id, "mentor_timeline_event_marking" => marking_params}) do
    marking = Transizion.get_mentor_timeline_event_marking!(marking_id) |> Repo.preload([:mentee, :mentor_timeline_event])
    mentee = marking.mentee
    event = marking.mentor_timeline_event

    case Transizion.update_mentor_timeline_event_marking(marking, marking_params) do
      {:ok, marking} ->
        conn
        |> redirect(
          to:
            Routes.mentor_timeline_path(conn, :index, mentee_id: marking.mentee_id) <>
              "#event-#{marking.mentor_timeline_event_id}"
        )

      {:error, %Ecto.Changeset{} = changeset} ->
        conn |> render("edit.html", changeset: changeset, marking: marking, mentee: mentee, event: event)
    end
  end
end
