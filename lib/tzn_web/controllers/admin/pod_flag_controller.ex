defmodule TznWeb.Admin.PodFlagController do
  use TznWeb, :controller

  def edit(conn, %{"id" => id}) do
    pod_flag = Tzn.Pods.get_flag(id)
    changeset = Tzn.Pods.change_flag(pod_flag)
    render(conn, "edit.html", flag: pod_flag, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pod_flag" => changes}) do
    flag = Tzn.Pods.get_flag(id)

    case Tzn.Pods.update_flag(flag, changes) do
      {:ok, flag} ->
        conn
        |> redirect(to: Routes.admin_pod_path(conn, :show, flag.pod_id))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", flag: flag, changeset: changeset)
    end
  end
end
