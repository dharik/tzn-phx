defmodule TznWeb.Admin.MentorController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Transizion.Mentor
  alias Tzn.Repo
  alias Tzn.Users

  plug :load_users

  def load_users(conn, _params) do
    users = Users.list_users()
    conn |> assign(:users, users)
  end

  def index(conn, _params) do
    render(conn, "index.html")
  end

  def index_json(conn, _) do
    mentors = Transizion.list_mentors() |> Repo.preload([:monthly_hour_counts, pods: [:mentee]])

    render(conn, "index.json", mentors: mentors)
  end

  def new(conn, _params) do
    changeset = Transizion.change_mentor(%Mentor{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mentor" => mentor_params}) do
    case Transizion.create_mentor(mentor_params) do
      {:ok, mentor} ->
        conn
        |> put_flash(:info, "Mentor created successfully.")
        |> redirect(to: Routes.admin_mentor_path(conn, :show, mentor))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    mentor =
      Transizion.get_mentor!(id)
      |> Repo.preload([
        :user,
        strategy_sessions: [pod: :mentee],
        timesheet_entries: [pod: :mentee]
      ])

    pods = Tzn.Pods.list_pods(mentor)

    render(conn, "show.html", mentor: mentor, pods: pods)
  end

  def edit(conn, %{"id" => id}) do
    mentor = Transizion.get_mentor!(id)
    changeset = Transizion.change_mentor(mentor)
    render(conn, "edit.html", mentor: mentor, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mentor" => mentor_params}) do
    mentor = Transizion.get_mentor!(id)

    case Transizion.update_mentor(mentor, mentor_params) do
      {:ok, mentor} ->
        conn
        |> put_flash(:info, "Mentor updated successfully.")
        |> redirect(to: Routes.admin_mentor_path(conn, :show, mentor))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mentor: mentor, changeset: changeset)
    end
  end

  #   def delete(conn, %{"id" => id}) do
  #     mentor = Transizion.get_mentor!(id)
  #     {:ok, _mentor} = Transizion.delete_mentor(mentor)

  #     conn
  #     |> put_flash(:info, "Mentor deleted successfully.")
  #     |> redirect(to: Routes.mentor_path(conn, :index))
  #   end
end
