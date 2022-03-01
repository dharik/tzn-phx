defmodule TznWeb.Mentor.MenteeController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Transizion.Mentee
  alias Tzn.Repo

  def index(conn, _params) do
    render(conn, "index.html", mentees: conn.assigns.mentees)
  end

  def new(conn, _params) do
    changeset = Transizion.change_mentee(%Mentee{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mentee" => mentee_params}) do
    case Transizion.create_mentee(mentee_params) do
      {:ok, mentee} ->
        conn
        |> put_flash(:info, "Mentee created successfully.")
        |> redirect(to: Routes.mentor_mentee_path(conn, :show, mentee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    mentee =
      Transizion.get_mentee!(id)
      |> Repo.preload([
        :mentor,
        :timesheet_entries,
        :hour_counts,
        questionnaires: [:question_set],
        strategy_sessions: [:mentor]
      ])

    changeset = Transizion.change_mentee(mentee)

    render(conn, "show.html", mentee: mentee, changeset: changeset)
  end

  def show_json(conn, %{"id" => id}) do
    mentee =
      Transizion.get_mentee!(id)
      |> Repo.preload([
        :mentor,
        :timesheet_entries,
        :hour_counts,
        questionnaires: [:question_set],
        strategy_sessions: [:mentor]
      ])

    json(conn, %{
      parent_todo_notes: mentee.parent_todo_notes,
      mentee_todo_notes: mentee.mentee_todo_notes,
      mentor_todo_notes: mentee.mentor_todo_notes,
      name: mentee.name
    })
  end

  def edit(conn, %{"id" => id}) do
    mentee = Transizion.get_mentee!(id)
    changeset = Transizion.change_mentee(mentee)
    render(conn, "edit.html", mentee: mentee, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mentee" => mentee_params}) do
    mentee = Transizion.get_mentee!(id)

    case Transizion.update_mentee(mentee, mentee_params, conn.assigns[:current_user]) do
      {:ok, mentee} ->
        conn
        |> put_flash(:info, "Mentee updated successfully.")
        |> redirect(to: Routes.mentor_mentee_path(conn, :show, mentee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mentee: mentee, changeset: changeset)
    end
  end

  def update(conn, %{"id" => id, "parent_todo_notes" => parent_todo_notes}) do
    mentee = Transizion.get_mentee!(id)

    case Transizion.update_mentee(mentee, %{"parent_todo_notes" => parent_todo_notes}, conn.assigns[:current_user]) do
      {:ok, mentee} -> json(conn, %{value: mentee.parent_todo_notes})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end

  def update(conn, %{"id" => id, "mentee_todo_notes" => mentee_todo_notes}) do
    mentee = Transizion.get_mentee!(id)
    case Transizion.update_mentee(mentee, %{"mentee_todo_notes" => mentee_todo_notes}, conn.assigns[:current_user]) do
      {:ok, mentee} -> json(conn, %{value: mentee.mentee_todo_notes})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end

  def update(conn, %{"id" => id, "mentor_todo_notes" => mentor_todo_notes}) do
    mentee = Transizion.get_mentee!(id)

    case Transizion.update_mentee(mentee, %{"mentor_todo_notes" => mentor_todo_notes}, conn.assigns[:current_user]) do
      {:ok, mentee} -> json(conn, %{value: mentee.mentor_todo_notes})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end

  def delete(conn, %{"id" => id}) do
    mentee = Transizion.get_mentee!(id)
    {:ok, _mentee} = Transizion.delete_mentee(mentee)

    conn
    |> put_flash(:info, "Mentee deleted successfully.")
    |> redirect(to: Routes.mentor_mentee_path(conn, :index))
  end
end
