defmodule TznWeb.AdminPodHours do
  use Phoenix.LiveView
  use Phoenix.HTML
  import TznWeb.ErrorHelpers

  def mount(_params, %{"pod_id" => pod_id, "current_user_id" => current_user_id}, socket) do
    pod = Tzn.Pods.get_pod!(pod_id)
    # TODO: permission checks that current_user can modify this pod

    {:ok,
     socket
     |> assign(:pod, pod)
     |> assign(:changeset, Tzn.Pods.change_pod(pod))
     |> assign(:current_user, Tzn.Users.get_user!(current_user_id))
     |> assign(:hours_by_grade, Tzn.HourTracking.hours_by_grade(pod) |> Map.new())}
  end

  def handle_event("validate", %{"pod" => pod_params}, socket) do
    updated_changeset =
      Tzn.Pods.change_pod(socket.assigns.pod, pod_params) |> Map.put(:action, :update)

    IO.inspect(updated_changeset)
    {:noreply, socket |> assign(:changeset, updated_changeset)}
  end

  def handle_event("save", %{"pod" => pod_params}, socket) do
    case Tzn.Pods.update_pod(socket.assigns.pod, pod_params, socket.assigns.current_user) do
      {:ok, updated_pod} ->
        {:noreply,
         socket
         |> assign(:pod, updated_pod)
         |> assign(:changeset, Tzn.Pods.change_pod(updated_pod))}

      {:error, _changeset} ->
        {:noreply, socket}
    end
  end
end
