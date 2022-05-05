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

  def show_json(conn, %{"id" => id}) do
    pod = Tzn.Pods.get_pod!(id)

    json(conn, %{
      parent_todo_notes: pod.parent_todo_notes,
      mentee_todo_notes: pod.mentee_todo_notes,
      mentor_todo_notes: pod.mentor_todo_notes,
      name: pod.mentee.name,
      grade: pod.mentee.grade
    })
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

  def update(conn, %{"id" => id, "parent_todo_notes" => parent_todo_notes}) do
    pod = Pods.get_pod!(id)

    case Pods.update_pod(
           pod,
           %{"parent_todo_notes" => parent_todo_notes},
           conn.assigns[:current_user]
         ) do
      {:ok, pod} -> json(conn, %{value: pod.parent_todo_notes})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end

  def update(conn, %{"id" => id, "mentee_todo_notes" => mentee_todo_notes}) do
    pod = Pods.get_pod!(id)

    case Pods.update_pod(
           pod,
           %{"mentee_todo_notes" => mentee_todo_notes},
           conn.assigns[:current_user]
         ) do
      {:ok, pod} -> json(conn, %{value: pod.mentee_todo_notes})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end

  def update(conn, %{"id" => id, "mentor_todo_notes" => mentor_todo_notes}) do
    pod = Pods.get_pod!(id)

    case Pods.update_pod(
           pod,
           %{"mentor_todo_notes" => mentor_todo_notes},
           conn.assigns[:current_user]
         ) do
      {:ok, pod} -> json(conn, %{value: pod.mentor_todo_notes})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end
end
