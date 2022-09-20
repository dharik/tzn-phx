defmodule TznWeb.Admin.SchoolAdminController do
  use TznWeb, :controller
  alias Tzn.Transizion
  alias Tzn.Repo

  def index(conn, _) do
    admins = Tzn.Profiles.list_school_admins() |> Repo.preload([:pod_groups, :user])
    render(conn, "index.html", admins: admins)
  end

  def edit(conn, %{"id" => school_admin_id}) do
    school_admin = Tzn.Profiles.get_school_admin(school_admin_id) |> Repo.preload([:pod_groups])
    changeset = Tzn.Profiles.change_school_admin(school_admin)
    render(conn, "edit.html", school_admin: school_admin, changeset: changeset)
  end

  def new(conn, _) do
    changeset = Tzn.Profiles.change_school_admin(%Tzn.DB.SchoolAdmin{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"school_admin" => school_admin_params}) do
    case Tzn.Profiles.create_school_admin(school_admin_params) do
      {:ok, _school_admin} ->
        conn
        |> redirect(to: Routes.admin_school_admin_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => school_admin_id, "school_admin" => changes}) do
    school_admin = Tzn.Profiles.get_school_admin(school_admin_id) |> Repo.preload([:pod_groups])

    case Tzn.Profiles.update_school_admin(school_admin, changes) do
      {:ok, _school_admin} ->
        redirect(conn, to: Routes.admin_school_admin_path(conn, :index))

      {:error, changeset} ->
        render(conn, "edit.html", school_admin: school_admin, changeset: changeset)
    end
  end
end
