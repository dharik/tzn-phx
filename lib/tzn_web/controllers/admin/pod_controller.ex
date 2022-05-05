defmodule TznWeb.Admin.PodController do
  use TznWeb, :controller
  alias Tzn.Transizion

  plug :load_mentor_list
  plug :load_mentees

  def load_mentor_list(conn, _) do
    mentors = Transizion.list_mentors() |> Enum.reject(fn m -> m.archived end)
    conn |> assign(:mentors, mentors)
  end

  def load_mentees(conn, _) do
    existing_mentees = Tzn.Mentee.list_mentees()
    conn |> assign(:mentees, existing_mentees)
  end

  def new(conn, %{"mentee_id" => mentee_id} = _params) do
    changeset =
      Tzn.Pods.change_pod(
        %Tzn.DB.Pod{
          active: true,
          college_list_access: true,
          scholarship_list_access: true,
          ecvo_list_access: true
        },
        %{mentee_id: mentee_id}
      )

    render(conn, "new.html", changeset: changeset)
  end

  def new(conn, _params) do
    changeset =
      Tzn.Pods.change_pod(%Tzn.DB.Pod{
        active: true,
        college_list_access: true,
        scholarship_list_access: true,
        ecvo_list_access: true
      })

    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"pod" => pod_params}) do
    case Tzn.Pods.create_pod(pod_params) do
      {:ok, pod} ->
        conn
        |> redirect(to: Routes.admin_pod_path(conn, :show, pod))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    pod = Tzn.Pods.get_pod!(id) |> Tzn.Pods.with_changes()

    render(conn, "show.html",
      mentee: pod.mentee,
      pod: pod
    )
  end

  def edit(conn, %{"id" => id}) do
    pod = Tzn.Pods.get_pod!(id)
    changeset = Tzn.Pods.change_pod(pod)
    render(conn, "edit.html", pod: pod, changeset: changeset)
  end

  def update(conn, %{"id" => id, "pod" => pod_params}) do
    pod = Tzn.Pods.get_pod!(id)

    case Tzn.Pods.update_pod(pod, pod_params, conn.assigns[:current_user]) do
      {:ok, pod} ->
        conn
        |> redirect(to: Routes.admin_pod_path(conn, :show, pod))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", pod: pod, changeset: changeset)
    end
  end
end
