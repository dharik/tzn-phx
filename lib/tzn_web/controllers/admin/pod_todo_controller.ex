defmodule TznWeb.Admin.PodTodoController do
  use TznWeb, :controller
  import Tzn.Pods

  def new(conn, %{"pod_id" => pod_id}) do
    pod = get_pod!(pod_id)
    changeset = admin_change_todo(%Tzn.DB.PodTodo{pod_id: pod.id})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pod_todo" => changes}) do

    case admin_create_todo(changes) do
      {:ok, todo} ->
        conn |> redirect(to: Routes.admin_pod_path(conn, :show, todo.pod_id))

      {:error, changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def edit(conn, %{"id" => id}) do
    pod_todo = get_todo(id)
    changeset = admin_change_todo(pod_todo)
    render(conn, "edit.html", todo: pod_todo, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pod_todo" => changes}) do
    pod_todo = get_todo(id)

    case admin_update_todo(pod_todo, changes) do
      {:ok, _updated_todo} ->
        conn
        |> redirect(to: Routes.admin_pod_path(conn, :show, pod_todo.pod_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", todo: pod_todo, changeset: changeset)
    end
  end
end
