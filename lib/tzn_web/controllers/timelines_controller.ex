defmodule TznWeb.TimelinesController do
  use TznWeb, :controller
  plug :put_layout, "live.html"
  import Phoenix.LiveView.Controller

  def show(conn, params) do
    # There's probably a nicer way of writing this
    # Get a timeline record by checking params, then session, then create one
    # Railway pattern with result form {:not_loaded, _access_key} | {timeline, access_key_used}
    {_, access_key_used} =
      {:not_loaded, :access_key}
      |> then(fn r ->
        if params["access_key"] == "new" do
          # Force create a new timeline record
          {:ok, timeline} = Tzn.Timelines.create_timeline()
          {timeline, timeline.access_key}
        else
          r
        end
      end)
      |> then(fn
        {:not_loaded, _} ->
          # Try loading via short UUID
          with {:ok, k} <- ShortUUID.decode(params["access_key"]),
               timeline <- Tzn.Timelines.get_timeline(k),
               true <- is_struct(timeline) do
            {timeline, k}
          else
            _ -> {:not_loaded, :access_key}
          end

        r ->
          r
      end)
      |> then(fn
        {:not_loaded, _} ->
          # Try loading via long UUID
          with k <- params["access_key"],
               true <- is_binary(k),
               timeline <- Tzn.Timelines.get_timeline(k),
               true <- is_struct(timeline) do
            {timeline, k}
          else
            _ -> {:not_loaded, :access_key}
          end

        r ->
          r
      end)
      |> then(fn
        {:not_loaded, _} ->
          # Try loading via session
          with k <- get_session(conn, :timeline_access_key),
               true <- is_binary(k),
               timeline <- Tzn.Timelines.get_timeline(k),
               true <- is_struct(timeline) do
            {timeline, k}
          else
            _ -> {:not_loaded, :access_key}
          end

        r ->
          r
      end)
      |> then(fn
        {:not_loaded, _} ->
          # Create a new timeline record
          {:ok, timeline} = Tzn.Timelines.create_timeline()
          {timeline, timeline.access_key}

        r ->
          r
      end)

    conn
    |> put_session(:timeline_access_key, access_key_used)
    |> live_render(TznWeb.Timeline, session: %{"access_key" => access_key_used})
  end

  def ical(conn, %{"access_key" => raw_key}) do
    key =
      case ShortUUID.decode(raw_key) do
        {:ok, decoded} -> decoded
        _ -> raw_key
      end

    timeline = Tzn.Timelines.get_timeline(key)

    ical =
      Tzn.Timelines.aggregate_calendar_events(timeline)
      |> Tzn.Timelines.to_ical(
        if timeline.pod do
          fully_loaded_pod = Tzn.Pods.get_pod!(timeline.pod.id)
          "#{fully_loaded_pod.mentee.name}'s Timeline"
        else
          "College Application Timeline from OrganizeU"
        end
      )

    if ua = Plug.Conn.get_req_header(conn, "user-agent") do
      {:ok, _} =
        Tzn.Timelines.update_timeline(timeline, %{
          last_ical_sync_at: Timex.now(),
          last_ical_sync_client: to_string(ua)
        })
    end

    send_download(conn, {:binary, ical},
      filename: key <> ".ics",
      content_type: "text/calendar",
      disposition: :inline
    )
  end

  def google_calendar(conn, %{"access_key" => raw_key}) do
    redirect(conn,
      external:
        ("https://calendar.google.com/calendar/r?cid=" <>
           TznWeb.Router.Helpers.timelines_url(TznWeb.Endpoint, :ical, raw_key))
        |> String.replace("https://", "http://")
    )
  end

  def apple_calendar(conn, %{"access_key" => raw_key}) do
    redirect(conn,
      external:
        TznWeb.Router.Helpers.timelines_url(TznWeb.Endpoint, :ical, raw_key)
        |> String.replace(["https://", "http://"], "webcal://")
    )
  end
end
