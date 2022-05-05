defmodule TznWeb.Admin.MenteeController do
  use TznWeb, :controller
  alias Tzn.Repo
  alias Tzn.Transizion.Mentee
  alias Tzn.Users

  plug :load_users

  def load_users(conn, _params) do
    users = Users.list_users()
    conn |> assign(:users, users)
  end

  def index(conn, _params) do
    mentees = Tzn.Mentee.list_mentees(:admin)
    render(conn, "index.html", mentees: mentees)
  end

  def new(conn, _params) do
    changeset = Tzn.Mentee.admin_change_mentee(%Mentee{})

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"mentee" => mentee_params}) do
    case Tzn.Mentee.admin_create_mentee(mentee_params) do
      {:ok, mentee} ->
        conn
        |> redirect(to: Routes.admin_mentee_path(conn, :show, mentee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    mentee =
      Tzn.Mentee.get_mentee!(id)
      |> Repo.preload([
        :user,
        changes: [:user]
      ])

    pods = Tzn.Pods.list_pods(mentee)

    render(conn, "show.html",
      mentee: mentee,
      pods: pods,
    )
  end

  def edit(conn, %{"id" => id}) do
    mentee = Tzn.Mentee.get_mentee!(id)
    changeset = Tzn.Mentee.admin_change_mentee(mentee)
    render(conn, "edit.html", mentee: mentee, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mentee" => mentee_params}) do
    mentee = Tzn.Mentee.get_mentee!(id)

    case Tzn.Mentee.admin_update_mentee(mentee, mentee_params, conn.assigns[:current_user]) do
      {:ok, mentee} ->
        conn
        |> redirect(to: Routes.admin_mentee_path(conn, :show, mentee))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mentee: mentee, changeset: changeset)
    end
  end
end
