defmodule TznWeb.MentorTimeline do
  use Phoenix.LiveView
  use Phoenix.HTML
  import TznWeb.ErrorHelpers
  alias Phoenix.LiveView.JS

  def mount(_params, _session = %{"access_key" => ak}, socket) do
    all_calendars = Tzn.Timelines.list_calendars(:public)
    timeline = Tzn.Timelines.get_timeline(ak)

    {:ok,
     socket
     |> assign(:timeline, timeline)
     |> assign(:include_past, false)
     |> assign(
       :calendars,
       MapSet.new(timeline.calendars)
     )
     |> assign(:hidden_ids, MapSet.new())
     |> assign(:search_query, "")
     |> assign(:all_calendars, all_calendars)
     |> assign_search_results()
     |> assign_events()
     |> assign(:export_changeset, Tzn.Timelines.change_timeline(timeline))
     |> assign(:export_complete, !is_nil(timeline.emailed_at))}
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
      (Tzn.Timelines.aggregate_calendar_events(
         socket.assigns.calendars
         |> Enum.reject(fn c -> MapSet.member?(socket.assigns.hidden_ids, c.id) end),
         socket.assigns.timeline.graduation_year,
         socket.assigns.include_past
       ) ++
         (pod.todos
          |> Enum.reject(& &1.deleted_at)) ++
         Tzn.Transizion.mentor_timeline_event_markings(pod.mentee))
      |> Enum.sort_by(
        fn
          %Tzn.DB.PodTodo{} = todo ->
            Date.new!(todo.due_date.year, todo.due_date.month, todo.due_date.day)

          %Tzn.Transizion.MentorTimelineEventMarking{} = marking ->
            Date.new!(
              Tzn.Timelines.event_year(
                socket.assigns.timeline.graduation_year,
                marking.mentor_timeline_event.grade,
                marking.mentor_timeline_event.date.month
              ),
              marking.mentor_timeline_event.date.month,
              marking.mentor_timeline_event.date.day
            )

          event ->
            Date.new!(event.year, event.month, event.day)
        end,
        {:asc, Date}
      )
      |> Enum.filter(fn e ->
        if socket.assigns.include_past do
          true
        else
          case e do
            %Tzn.DB.PodTodo{} = e ->
              Timex.after?(
                Timex.Date.new!(e.due_date.year, e.due_date.month, e.due_date.day),
                Timex.now()
              )

            %Tzn.Transizion.MentorTimelineEventMarking{} = m ->
              Timex.after?(
                Date.new!(
                  Tzn.Timelines.event_year(
                    socket.assigns.timeline.graduation_year,
                    m.mentor_timeline_event.grade,
                    m.mentor_timeline_event.date.month
                  ),
                  m.mentor_timeline_event.date.month,
                  m.mentor_timeline_event.date.day
                ),
                Timex.now()
              )

            _ ->
              Timex.after?(Timex.Date.new!(e.year, e.month, e.day), Timex.now())
          end
        end
      end)
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

  # def handle_event("validate_export", %{"timeline" => timeline_params}, socket) do
  #   updated_changeset =
  #     Tzn.Timelines.change_timeline(socket.assigns.timeline, timeline_params)
  #     |> Map.put(:action, :update)

  #   {:noreply, assign(socket, :export_changeset, updated_changeset)}
  # end

  def handle_event("export", %{"timeline" => timeline_params}, socket) do
    case Tzn.Timelines.update_timeline(socket.assigns.timeline, timeline_params) do
      {:ok, timeline} ->
        Task.async(fn ->
          Tzn.Emails.TimelineExport.send_timeline(timeline)
        end)

        {:noreply,
         socket
         |> assign(:timeline, timeline)
         |> assign(:export_changeset, Tzn.Timelines.change_timeline(timeline))
         |> assign(:export_complete, true)}

      {:error, changeset} ->
        {:noreply, socket |> assign(:export_changeset, changeset)}
    end
  end
end
