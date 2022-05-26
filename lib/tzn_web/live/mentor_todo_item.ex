defmodule TznWeb.MentorTodoItem do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  import TznWeb.ErrorHelpers

  def mount(socket) do
    {:ok, socket |> assign(:item, nil) |> assign(:changeset, nil)}
  end

  def update(%{item: item}, socket) do
    {:ok, socket |> assign(:item, item)}
  end

  def handle_event("edit", _params, socket) do
    {:noreply,
     socket
     |> assign(:changeset, Tzn.Pods.change_todo(socket.assigns.item))}
  end

  def handle_event("close", _params, socket) do
    {:noreply,
     socket
     |> assign(:changeset, nil)}
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

  def handle_event("delete", _params, socket) do
    case Tzn.Pods.update_todo(socket.assigns.item, %{deleted_at: Timex.now()}) do
      {:ok, updated_todo} ->
        send(self(), :todo_updated)
        {:noreply, socket |> assign(:item, updated_todo)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("undo_delete", _params, socket) do
    case Tzn.Pods.update_todo(socket.assigns.item, %{deleted_at: nil}) do
      {:ok, updated_todo} ->
        send(self(), :todo_updated)
        {:noreply, socket |> assign(:item, updated_todo)}

      {:error, _} ->
        {:noreply, socket}
    end
  end

  def handle_event("validate", %{"pod_todo" => attrs}, socket) do
    {:noreply,
     case Tzn.Pods.update_todo(socket.assigns.item, attrs) do
       {:ok, updated_item} ->
         send(self(), :todo_updated)
         socket |> assign(:item, updated_item)

       {:error, changeset} ->
         socket |> assign(:changeset, changeset)
     end}
  end
end
