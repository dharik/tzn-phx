defmodule TznWeb.Mentor.MenteeController do
  use TznWeb, :controller

  alias Tzn.Mentee

  # The actaul mentor should just be sent to the right pod
  # Specialist mentors can see limited details
  # TODO: Figure out what to do when the mentee has multiple pods
  def show(conn, %{"id" => mentee_id}) do
    if best_pod = Tzn.Mentee.get_mentee!(mentee_id) |> Tzn.Pods.list_pods() |> List.first() do
      redirect(conn, to: Routes.mentor_pod_path(conn, :show, best_pod))
    else
      redirect(conn, to: Routes.mentor_pod_path(conn, :index))
    end
  end

  def edit(conn, %{"id" => id}) do
    mentee = Mentee.get_mentee!(id)
    changeset = Mentee.change_mentee(mentee)
    render(conn, "edit.html", mentee: mentee, changeset: changeset)
  end

  def update(conn, %{"id" => id, "mentee" => mentee_params}) do
    mentee = Mentee.get_mentee!(id)

    case Mentee.update_mentee(mentee, mentee_params, conn.assigns[:current_user]) do
      {:ok, _mentee} ->
        # TODO: figure out what to do when the mentee has multiple pods
        if pod = Tzn.Pods.list_pods(mentee) |> List.first() do
          redirect(conn, to: Routes.mentor_pod_path(conn, :show, pod))
        else
          redirect(conn, to: Routes.mentor_pod_path(conn, :index))
        end

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", mentee: mentee, changeset: changeset)
    end
  end
end
