defmodule TznWeb.AdminPodGroup do
  use Phoenix.LiveView
  use Phoenix.HTML
  import TznWeb.ErrorHelpers

  def mount(
        _params,
        %{"pod_group_id" => pod_group_id, "current_user_id" => current_user_id},
        socket
      ) do
    Tzn.Policy.assert_admin(Tzn.Users.get_user!(current_user_id))
    group = Tzn.PodGroups.get_group(pod_group_id)

    {:ok,
     socket
     |> assign(:group, group)
     |> assign(:search_query, "")
     |> assign_pods()
     |> assign_search_result_pods()
     |> assign(:all_school_admins, Tzn.Profiles.list_school_admins())}
  end

  def reload_group(socket) do
    group = Tzn.PodGroups.get_group(socket.assigns.group.id)
    assign(socket, :group, group)
  end

  def assign_pods(socket) do
    reloaded_group = Tzn.PodGroups.get_group(socket.assigns.group.id)
    assign(socket, :pods, reloaded_group.pods)
  end

  def assign_search_result_pods(socket) do
    results =
      if socket.assigns.search_query == "" do
        Tzn.Pods.list_pods(:admin)
        |> Enum.filter(& &1.mentee)
        |> Enum.reject(& &1.mentee.archived)
        |> Enum.sort_by(& &1.updated_at, {:desc, NaiveDateTime})
        |> Enum.take(5)
      else
        Tzn.Pods.list_pods(:admin)
        |> Enum.filter(& &1.mentee)
        |> Enum.reject(& &1.mentee.archived)
        # |> Enum.reject(fn pod ->
        #   Enum.find(socket.assigns.group.pods, nil, fn p -> p.id == pod.id end)
        # end)
        |> Enum.sort_by(fn pod ->
          content = String.downcase(pod.mentee.name || "" <> " " <> pod.mentee.email || "")
          query = String.downcase(socket.assigns.search_query)

          subset_score =
            if String.contains?(query, query) do
              if String.starts_with?(query, query) do
                2.0
              else
                1.0
              end
            else
              0.0
            end

          similarity_score =
            TheFuzz.Similarity.Tversky.compare(
              query,
              content,
              %{n_gram_size: 2, alpha: 2, beta: 1}
            ) || 0.0

          subset_score + similarity_score
        end)
        |> Enum.reverse()
        |> Enum.take(5)
      end

    assign(socket, :search_result_pods, results)
  end

  def handle_event("search", %{"q" => q}, socket) do
    {:noreply, socket |> assign(:search_query, q) |> assign_search_result_pods()}
  end

  def handle_event("add_pod", %{"id" => pod_id}, socket) do
    Tzn.PodGroups.add_to_group(socket.assigns.group, %Tzn.DB.Pod{id: pod_id})
    {:noreply, socket |> assign_pods() |> assign_search_result_pods()}
  end

  def handle_event("remove_pod", %{"id" => pod_id}, socket) do
    Tzn.PodGroups.remove_from_group(socket.assigns.group, %Tzn.DB.Pod{id: pod_id})
    {:noreply, socket |> assign_pods() |> assign_search_result_pods()}
  end

  def handle_event("add_school_admin", %{"school_admin_id" => school_admin_id}, socket) do
    sa = Tzn.Profiles.get_school_admin(school_admin_id)
    Tzn.PodGroups.add_to_group(socket.assigns.group, sa)
    {:noreply, socket |> reload_group()}
  end

  def handle_event("remove_school_admin", %{"id" => school_admin_id}, socket) do
    sa = Tzn.Profiles.get_school_admin(school_admin_id)
    Tzn.PodGroups.remove_from_group(socket.assigns.group, sa)
    {:noreply, socket |> reload_group() }
  end
end
