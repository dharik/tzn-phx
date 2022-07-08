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
end
