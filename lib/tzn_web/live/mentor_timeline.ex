defmodule TznWeb.MentorTimeline do
  use Phoenix.LiveView
  use Phoenix.HTML

  def mount(_params, _session = %{"access_key" => ak}, socket) do
    all_calendars = Tzn.Timelines.list_calendars(:public)
    timeline = Tzn.Timelines.get_timeline(ak)

    {:ok,
     socket
     |> assign(:timeline, timeline)
     |> assign(:include_past, false)
     |> assign(:include_hidden_events, false)
     |> assign(
       :calendars,
       MapSet.new(timeline.calendars)
     )
     |> assign(:hidden_ids, MapSet.new())
     |> assign(:search_query, "")
     |> assign(:all_calendars, all_calendars)
     |> assign_search_results()
     |> assign_events()}
  end

  def handle_event("toggle_calendar", %{"id" => calendar_id}, socket) do
    calendar_id = String.to_integer(calendar_id)

    if MapSet.member?(socket.assigns.hidden_ids, calendar_id) do
      {:noreply,
       socket
       |> assign(:hidden_ids, MapSet.delete(socket.assigns.hidden_ids, calendar_id))
       |> assign_events()}
    else
      {:noreply,
       socket
       |> assign(:hidden_ids, MapSet.put(socket.assigns.hidden_ids, calendar_id))
       |> assign_events()}
    end
  end

  def handle_event("add_calendar", %{"id" => calendar_id}, socket) do
    calendar_id = String.to_integer(calendar_id)
    calendar = Tzn.Timelines.get_calendar(calendar_id)

    {:noreply,
     socket
     |> add_calendar_to_socket(calendar)}
  end

  def handle_event("toggle_past", _, socket) do
    {:noreply,
     socket
     |> assign(:include_past, !socket.assigns.include_past)
     |> assign_events()}
  end
  def handle_event("toggle_hidden_events", _, socket) do
    {:noreply,
     socket
     |> assign(:include_hidden_events, !socket.assigns.include_hidden_events)
     |> assign_events()}
  end

  def handle_event("complete_calendar_event", %{"id" => calendar_event_id}, socket) do
    {:ok, _} =
      Tzn.Timelines.get_event(calendar_event_id)
      |> Tzn.Timelines.mark_calendar_event(socket.assigns.timeline, %{completed: true})

    {:noreply, socket |> assign_events()}
  end

  def handle_event("incomplete_calendar_event", %{"id" => calendar_event_id}, socket) do
    {:ok, _} =
      Tzn.Timelines.get_event(calendar_event_id)
      |> Tzn.Timelines.mark_calendar_event(socket.assigns.timeline, %{completed: false})

    {:noreply, socket |> assign_events()}
  end

  def handle_event("hide_calendar_event", %{"id" => calendar_event_id}, socket) do
    {:ok, _} =
      Tzn.Timelines.get_event(calendar_event_id)
      |> Tzn.Timelines.mark_calendar_event(socket.assigns.timeline, %{hidden: true})

    {:noreply, socket |> assign_events()}
  end

  def handle_event("unhide_calendar_event", %{"id" => calendar_event_id}, socket) do
    {:ok, _} =
      Tzn.Timelines.get_event(calendar_event_id)
      |> Tzn.Timelines.mark_calendar_event(socket.assigns.timeline, %{hidden: false})

    {:noreply, socket |> assign_events()}
  end

  def handle_event("complete_todo", %{"id" => todo_id}, socket) do
    todo = Tzn.Pods.get_todo(todo_id)
    Tzn.Pods.update_todo_complete_state(todo, %{completed: true, completed_changed_by: "mentor" })
    {:noreply, socket |> assign_events()}
  end

  def handle_event("incomplete_todo", %{"id" => todo_id}, socket) do
    todo = Tzn.Pods.get_todo(todo_id)
    Tzn.Pods.update_todo_complete_state(todo, %{completed: false, completed_changed_by: "mentor" })
    {:noreply, socket |> assign_events()}
  end

  # TODO
  def handle_event("hide_todo", %{"id" => todo_id}, socket) do
    {:noreply, socket}
  end

  # TODO
  def handle_event("unhide_todo", %{"id" => todo_id}, socket) do
    {:noreply, socket}
  end

  def handle_event("remove_calendar", %{"id" => calendar_id}, socket) do
    calendar_id = String.to_integer(calendar_id)
    calendar = Tzn.Timelines.get_calendar(calendar_id)
    new_calendars = MapSet.delete(socket.assigns.calendars, calendar)

    {:ok, timeline} =
      Tzn.Timelines.set_calendars_for_timeline(
        MapSet.to_list(new_calendars),
        socket.assigns.timeline
      )

    {:noreply,
     socket
     |> assign(:calendars, new_calendars)
     |> assign(:timeline, timeline)
     |> assign_search_results()
     |> assign_events()}
  end

  def add_calendar_to_socket(socket, calendar) do
    new_calendars = MapSet.put(socket.assigns.calendars, calendar)

    {:ok, timeline} =
      Tzn.Timelines.set_calendars_for_timeline(
        MapSet.to_list(new_calendars),
        socket.assigns.timeline
      )

    socket
    |> assign(:calendars, new_calendars)
    |> assign(:timeline, timeline)
    |> assign_search_results()
    |> assign_events()
  end

  def handle_event("search", %{"q" => q}, socket) do
    {:noreply, socket |> assign(:search_query, q) |> assign_search_results()}
  end

  def handle_event("search_submit", %{"q" => q}, socket) do
    top_result = socket.assigns.search_results |> List.first()

    if top_result do
      {:noreply,
       socket
       |> assign(:search_query, q)
       |> add_calendar_to_socket(top_result)
       |> assign_search_results()}
    else
      {:noreply,
       socket
       |> assign(:search_query, q)
       |> assign_search_results()}
    end
  end

  def assign_events(socket) do
    pod = Tzn.Pods.get_pod!(socket.assigns.timeline.pod.id)

    assign(
      socket,
      :events,
      Tzn.Timelines.aggregate_calendar_events(pod)
      |> Enum.reject(fn e ->
        case e do
          %{calendar: c} -> MapSet.member?(socket.assigns.hidden_ids, c.id)
          _ -> false
        end
      end)
      |> Enum.filter(fn e ->
        if socket.assigns.include_past do
          true
        else
          Timex.after?(
            e.date,
            Timex.now()
          )
        end
      end)
      |> Enum.reject(fn e ->
        if socket.assigns.include_hidden_events do
          false
        else
          e.hidden
        end
      end)
      |> Enum.sort_by(fn e -> e.date end, {:asc, Date})
    )
  end

  def assign_search_results(socket) do
    current_ids = MapSet.to_list(socket.assigns.calendars) |> Enum.map(& &1.id) |> MapSet.new()

    r =
      if String.length(socket.assigns.search_query) > 0 do
        socket.assigns.all_calendars
        |> Enum.sort_by(fn c ->
          q = String.downcase(socket.assigns.search_query)
          n = String.downcase(c.name) <> String.downcase(c.searchable_name || "")

          subset_score =
            if String.contains?(n, q) do
              if String.starts_with?(n, q) do
                2.0
              else
                1.0
              end
            else
              0.0
            end

          similarity_score =
            TheFuzz.Similarity.Tversky.compare(
              q,
              n,
              %{n_gram_size: 2, alpha: 2, beta: 1}
            ) || 0.0

          subset_score + similarity_score
        end)
        |> Enum.reverse()
        |> Enum.reduce_while([], fn cal, acc ->
          non_subscribed_count =
            Enum.count(acc, fn c ->
              !MapSet.member?(current_ids, c.id)
            end)

          if non_subscribed_count <= 5 do
            {:cont, acc ++ [cal]}
          else
            {:halt, acc}
          end
        end)
      else
        []
      end

    socket |> assign(:search_results, r)
  end
end
