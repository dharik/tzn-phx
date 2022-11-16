defmodule TznWeb.MentorMilestoneItem do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  import TznWeb.ErrorHelpers

  def mount(socket) do
    {:ok, socket |> assign(:item, nil) |> assign(:changeset, nil) |> assign(:is_editing_date, false)}
  end

  def update(%{item: item}, socket) do
    {:ok, socket |> assign(:item, item) |> assign(:changeset, Tzn.Pods.change_todo(item))}
  end

  def handle_event("edit_date", _params, socket) do
    {:noreply,
     socket
     |> assign(:is_editing_date, true)}
  end


  def handle_event("close_date", _params, socket) do
    {:noreply,
     socket
     |> assign(:is_editing_date, false)}
  end

  def handle_event("mark_complete", _params, socket) do
    case Tzn.Pods.update_todo_complete_state(socket.assigns.item, %{completed: true, completed_changed_by: "mentor"}) do
      {:ok, updated_todo} ->
        send(self(), :todo_updated)
        {:noreply, socket |> assign(:item, updated_todo)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("mark_incomplete", _params, socket) do
    case Tzn.Pods.update_todo_complete_state(socket.assigns.item, %{completed: false, completed_changed_by: "mentor"}) do
      {:ok, updated_todo} ->
        send(self(), :todo_updated)
        {:noreply, socket |> assign(:item, updated_todo)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("star", _params, socket) do
    pod = Tzn.Pods.get_pod(socket.assigns.item.pod_id)
    current_priority_todo = pod.todos |> Enum.filter(& &1.is_priority) |> List.first()

    if current_priority_todo do
      {:ok, unstarred_milestone} = Tzn.Pods.update_todo(current_priority_todo, %{
        is_priority: false
      })

      # Update the mielstone that was juts unstarred
      send_update(TznWeb.MentorMilestoneItem, id: unstarred_milestone.id, item: unstarred_milestone)
    end

    case Tzn.Pods.update_todo(socket.assigns.item, %{is_priority: true}) do
      {:ok, updated_todo} ->
        send(self(), :todo_updated)
        {:noreply, socket |> assign(:item, updated_todo)}

      {:error, _} ->
        {:noreply, socket}
    end
  end


  def handle_event("save", %{"pod_todo" => attrs}, socket) do
    {:noreply,
     case Tzn.Pods.update_todo(socket.assigns.item, attrs) do
       {:ok, updated_item} ->
         send(self(), :todo_updated)
         socket |> assign(:item, updated_item) |> assign(:changeset, Tzn.Pods.change_todo(updated_item))

       {:error, changeset} ->
         socket |> assign(:changeset, changeset)
     end}
  end
end
