defmodule TznWeb.MentorFlagEditor do
  use Phoenix.LiveComponent
  use Phoenix.HTML
  import TznWeb.ErrorHelpers
  alias Tzn.DB.PodFlag
  alias Tzn.Pods
  alias Phoenix.LiveView.JS

  def mount(socket) do
    {:ok,
     socket
     |> assign(:pod, nil)
     |> assign(:new_flag_changeset, nil)
     |> assign(:show_all, false)
     |> assign(:can_show_all, false)
     |> assign(:all_flags, [])
     |> assign(:flags_to_show, [])}
  end

  def update(%{pod: pod}, socket) do
    {:ok,
     socket
     |> assign(:pod, pod)
     |> reload_flags()}
  end

  def reload_flags(socket) do
    refreshed_pod = Tzn.Pods.get_pod!(socket.assigns.pod.id)
    all_flags = refreshed_pod.flags |> Pods.sort_flags()

    initial_flags_to_show =
      all_flags
      |> Enum.filter(fn f ->
        Tzn.Util.within_n_days_ago(f.updated_at, 7) || f.status != "resolved"
      end)

    can_show_all =
      !socket.assigns.show_all && Enum.count(all_flags) > Enum.count(initial_flags_to_show)

    if socket.assigns.show_all do
      socket
      |> assign(:can_show_all, can_show_all)
      |> assign(:all_flags, all_flags)
      |> assign(:flags_to_show, all_flags)
    else
      socket
      |> assign(:can_show_all, can_show_all)
      |> assign(:all_flags, all_flags)
      |> assign(:flags_to_show, initial_flags_to_show)
    end
  end

  def handle_event("show_all", _params, socket) do
    {:noreply,
     socket
     |> assign(:show_all, true)
     |> reload_flags()}
  end

  def handle_event("start_create_flag", _params, socket) do
    {:noreply,
     socket
     |> assign(
       :new_flag_changeset,
       Tzn.Pods.change_flag(%PodFlag{pod_id: socket.assigns.pod.id, status: "open"})
     )}
  end

  def handle_event("stop_create_flag", _params, socket) do
    {:noreply,
     socket
     |> assign(:new_flag_changeset, nil)}
  end

  def handle_event("save", _, socket) do
    case Tzn.Pods.create_flag(socket.assigns.new_flag_changeset) do
      {:ok, _flag} ->
        {:noreply,
         socket
         |> assign(:new_flag_changeset, nil)
         |> reload_flags()}

      {:error, changeset} ->
        {:noreply,
         socket
         |> assign(:new_flag_changeset, changeset)}
    end
  end

  def handle_event("validate", %{"pod_flag" => attrs}, socket) do
    {:noreply,
     socket
     |> assign(
       :new_flag_changeset,
       Tzn.Pods.change_flag(
         %PodFlag{pod_id: socket.assigns.pod.id, status: "open"},
         attrs
       )
       |> Map.put(:action, :insert)
     )}
  end
end
