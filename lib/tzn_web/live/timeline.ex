defmodule TznWeb.Timeline do
  use Phoenix.LiveView
  use Phoenix.HTML
  import TznWeb.ErrorHelpers

  def mount(_params, _session = %{"access_key" => ak}, socket) do
    all_calendars = Tzn.Timelines.list_calendars(:public)
    timeline = Tzn.Timelines.get_timeline(ak)

    {:ok,
     socket
     |> assign(
       :calendars,
       MapSet.new(timeline.calendars)
     )
     |> assign(:hidden_ids, MapSet.new())
     |> assign(:search_query, "")
     |> assign(:grad_year, timeline.graduation_year)
     |> assign(:all_calendars, all_calendars)
     |> assign_search_results()
     |> assign_events()
     |> assign(:timeline, timeline)
     |> assign(:export_changeset, Tzn.Timelines.change_timeline(timeline))
     |> assign(:export_complete, !is_nil(timeline.emailed_at))
     |> assign(:readonly, ak == timeline.readonly_access_key)}
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
    new_calendars = MapSet.put(socket.assigns.calendars, calendar)

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

  def handle_event("search", %{"q" => q}, socket) do
    {:noreply, socket |> assign(:search_query, q) |> assign_search_results()}
  end

  def handle_event("set_grad_year", %{"grad_year" => year}, socket) do
    {:ok, timeline} =
      Tzn.Timelines.update_timeline(socket.assigns.timeline, %{graduation_year: year})

    {:noreply,
     socket
     |> assign(:grad_year, String.to_integer(year))
     |> assign_events()
     |> assign(:timeline, timeline)}
  end

  def assign_events(socket) do
    assign(
      socket,
      :events,
      Tzn.Timelines.aggregate_calendar_events(
        socket.assigns.calendars
        |> Enum.reject(fn c -> MapSet.member?(socket.assigns.hidden_ids, c.id) end),
        socket.assigns.grad_year
      )
    )
  end

  def assign_search_results(socket) do
    current_ids = MapSet.to_list(socket.assigns.calendars) |> Enum.map(& &1.id) |> MapSet.new()

    r =
      socket.assigns.all_calendars
      |> Enum.reject(fn c ->
        MapSet.member?(current_ids, c.id)
      end)
      |> Enum.sort_by(fn c ->
        if String.length(socket.assigns.search_query) > 0 do
          1.0 -
            TheFuzz.Similarity.Overlap.compare(
              String.downcase(socket.assigns.search_query),
              String.downcase(c.name),
              max(3, String.length(socket.assigns.search_query))
            )
        else
          c.name
        end
      end)
      |> Enum.take(3)

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
