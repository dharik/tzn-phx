defmodule TznWeb.MentorPlugs do
  import Plug.Conn
  alias Tzn.Transizion
  require Logger

  def load_mentor_profile(conn, _) do
    mentor_profile = Transizion.get_mentor_profile(conn.assigns.current_user.id)

    conn |> assign(:current_mentor, mentor_profile) |> log_mentor() |> log_browser()
  end

  def log_mentor(conn) do
    if conn.assigns.current_mentor do
      Logger.info("Current Mentor: #{conn.assigns.current_mentor.name} (#{conn.assigns.current_mentor.id})")
    end

    conn
  end

  def log_browser(conn) do
    if ua = Plug.Conn.get_req_header(conn, "user-agent") do
      Logger.info("Browser: #{ua}")
    end

    conn
  end

  def ensure_mentor_profile(conn, _) do
    if conn.assigns.current_mentor do
      conn
    else
      Logger.error("No mentor profile")
      conn |> halt
    end
  end

  def load_pods(conn, _) do
    assign(
      conn,
      :pods,
      Tzn.Pods.list_pods(conn.assigns.current_mentor) |> Enum.filter(& &1.active)
    )
  end
end
