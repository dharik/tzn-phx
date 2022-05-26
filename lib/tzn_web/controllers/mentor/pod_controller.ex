defmodule TznWeb.Mentor.PodController do
  use TznWeb, :controller

  alias Tzn.Pods

  def index(conn, _params) do
    pods =
      Tzn.Pods.list_pods(conn.assigns.current_mentor)
      |> Enum.filter(& &1.mentee)
      |> Enum.filter(& &1.active)

    render(conn, "index.html", pods: pods)
  end

  def show(conn, %{"id" => id}) do
    pod = Tzn.Pods.get_pod(id)
    mentee = pod.mentee

    changeset = Pods.change_pod(pod) # For internal notes

    render(conn, "show.html", mentee: mentee, changeset: changeset, pod: pod)
  end


  def update(conn, %{"id" => id, "pod" => pod_params}) do
    pod = Pods.get_pod!(id)

    case Pods.update_pod(pod, pod_params, conn.assigns[:current_user]) do
      {:ok, pod} ->
        conn
        |> redirect(to: Routes.mentor_pod_path(conn, :show, pod))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", pod: pod, changeset: changeset)
    end
  end
end
