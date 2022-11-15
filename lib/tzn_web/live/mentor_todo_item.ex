defmodule TznWeb.MentorTodoItem do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  import TznWeb.ErrorHelpers

  def mount(socket) do
    {:ok, socket |> assign(:item, nil) |> assign(:changeset, nil) |> assign(:is_editing_text, false) |> assign(:is_editing_date, false)}
  end

  def update(%{item: item}, socket) do
    {:ok, socket |> assign(:item, item) |> assign(:changeset, Tzn.Pods.change_todo(item))}
  end

  def handle_event("edit_text", _params, socket) do
    {:noreply,
     socket
     |> assign(:is_editing_text, true)}
  end

  def handle_event("edit_date", _params, socket) do
    {:noreply,
     socket
     |> assign(:is_editing_date, true)}
  end

  def handle_event("close_text", _params, socket) do
    {:noreply,
     socket
     |> assign(:is_editing_text, false)}
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
