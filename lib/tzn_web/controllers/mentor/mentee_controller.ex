defmodule TznWeb.Mentor.MenteeController do
  use TznWeb, :controller

  alias Tzn.Mentee
  alias Tzn.Repo

  def index(conn, _params) do
    render(conn, "index.html", mentees: conn.assigns.mentees)
  end

  def show(conn, %{"id" => id}) do
    mentee =
      Mentee.get_mentee!(id)
      |> Repo.preload([
        :mentor,
        :timesheet_entries,
        :hour_counts,
        questionnaires: [:question_set]
      ])

    changeset = Mentee.change_mentee(mentee)

    # should load a pod (which has mentee info)
    # then display it all at once

    render(conn, "show.html", mentee: mentee, changeset: changeset)
  end

  def show_json(conn, %{"id" => id}) do
    mentee =
      Mentee.get_mentee!(id)
      |> Repo.preload([
        :mentor,
        :timesheet_entries,
        :hour_counts,
        questionnaires: [:question_set]
      ])

    json(conn, %{
      parent_todo_notes: mentee.parent_todo_notes,
      mentee_todo_notes: mentee.mentee_todo_notes,
      mentor_todo_notes: mentee.mentor_todo_notes,
      name: mentee.name,
      grade: mentee.grade
    })
  end

  def edit(conn, %{"id" => id}) do
    mentee = Mentee.get_mentee!(id)
    changeset = Mentee.change_mentee(mentee)
    render(conn, "edit.html", mentee: mentee, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mentee" => mentee_params}) do
    mentee = Mentee.get_mentee!(id)

    case Mentee.update_mentee(mentee, mentee_params, conn.assigns[:current_user]) do
      {:ok, mentee} ->
        conn
        |> redirect(to: Routes.mentor_mentee_path(conn, :show, mentee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mentee: mentee, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "parent_todo_notes" => parent_todo_notes}) do
    mentee = Mentee.get_mentee!(id)

    case Mentee.update_mentee(
           mentee,
           %{"parent_todo_notes" => parent_todo_notes},
           conn.assigns[:current_user]
         ) do
      {:ok, mentee} -> json(conn, %{value: mentee.parent_todo_notes})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end

  def update(conn, %{"id" => id, "mentee_todo_notes" => mentee_todo_notes}) do
    mentee = Mentee.get_mentee!(id)

    case Mentee.update_mentee(
           mentee,
           %{"mentee_todo_notes" => mentee_todo_notes},
           conn.assigns[:current_user]
         ) do
      {:ok, mentee} -> json(conn, %{value: mentee.mentee_todo_notes})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end

  def update(conn, %{"id" => id, "mentor_todo_notes" => mentor_todo_notes}) do
    mentee = Mentee.get_mentee!(id)

    case Mentee.update_mentee(
           mentee,
           %{"mentor_todo_notes" => mentor_todo_notes},
           conn.assigns[:current_user]
         ) do
      {:ok, mentee} -> json(conn, %{value: mentee.mentor_todo_notes})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end
end
