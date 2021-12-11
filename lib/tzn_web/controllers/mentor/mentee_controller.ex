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

  def edit(conn, %{"id" => id}) do
    mentee = Transizion.get_mentee!(id)
    changeset = Transizion.change_mentee(mentee)
    render(conn, "edit.html", mentee: mentee, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mentee" => mentee_params}) do
    mentee = Transizion.get_mentee!(id)

    case Transizion.update_mentee(mentee, mentee_params) do
      {:ok, mentee} ->
        conn
        |> put_flash(:info, "Mentee updated successfully.")
        |> redirect(to: Routes.mentor_mentee_path(conn, :show, mentee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mentee: mentee, changeset: changeset)
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
