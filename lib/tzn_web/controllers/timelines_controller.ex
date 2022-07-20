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

  def ical(conn, params = %{"access_key" => raw_key}) do
    key =
      case ShortUUID.decode(raw_key) do
        {:ok, decoded} -> decoded
        _ -> raw_key
      end

    timeline = Tzn.Timelines.get_timeline(key)

    events =
      Tzn.Timelines.aggregate_calendar_events(
        timeline.calendars,
        timeline.graduation_year
      )
      |> Enum.map(fn e ->
        calendar = Enum.find(timeline.calendars, nil, fn c -> e.calendar_id == c.id end)

        [
          description: HtmlSanitizeEx.strip_tags(e.description),
          summary:
            if calendar.type == "college_cyclic" do
              "#{e.name} (#{calendar.name})"
            else
              e.name
            end,
          dtstart: [
            VALUE: "DATE",
            value:
              Timex.Date.new!(e.year, e.month, e.day)
              |> Timex.to_datetime()
              |> Timex.format!("{YYYY}{0M}{0D}")
          ],
          dtstamp: Timex.Date.new!(e.year, e.month, e.day) |> Timex.to_datetime(),
          # Later on the hash might be cz-todo-{id}
          uid: :crypto.hash(:sha, "organizeu-event-#{e.id}") |> Base.encode32()
        ]
      end)

    root =
      Calibex.new_root(
        vevent: events,
        prodid: "-//Transizion//OrganizeU",
        last_modified: Timex.now(),
        name: "College Application Timeline from OrganizeU",
        "X-WR-CALNAME": "College Application Timeline from OrganizeU",
        "REFRESH-INTERVAL": [VALUE: "DURATION", value: "PT24H"]
      )

    send_download(conn, {:binary, Calibex.encode(root)},
      filename: key <> ".ics",
      content_type: "text/calendar",
      disposition: :inline
    )
  end
end
