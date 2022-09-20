defmodule TznWeb.Admin.PodGroupController do
  use TznWeb, :controller
  alias Tzn.Transizion

  def index(conn, _) do
    groups = Tzn.PodGroups.list_groups(conn.assigns.current_admin)
    render(conn, "index.html", groups: groups)
  end

  def show(conn, %{"id" => group_id}) do
    group = Tzn.PodGroups.get_group(group_id)
    render(conn, "show.html", group: group)
  end

  def edit(conn, %{"id" => group_id}) do
    group = Tzn.PodGroups.get_group(group_id)
    changeset = Tzn.PodGroups.change_group(group)

    render(conn, "edit.html", group: group, changeset: changeset)
  end

  def new(conn, _) do
    changeset = Tzn.PodGroups.change_group(%Tzn.DB.PodGroup{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pod_group" => group_params}) do
    case Tzn.PodGroups.create_group(group_params) do
      {:ok, group} ->
        conn
        |> redirect(to: Routes.admin_pod_group_path(conn, :show, group))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def update(conn, %{"id" => group_id, "pod_group" => changes}) do
    group = Tzn.PodGroups.get_group(group_id)

    case Tzn.PodGroups.update_group(group, changes) do
      {:ok, group} ->
        render(conn, "show.html", group: group)

      {:error, changeset} ->
        render(conn, "edit.html", group: group, changeset: changeset)
    end
  end
end
