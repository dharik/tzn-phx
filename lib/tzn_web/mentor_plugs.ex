defmodule TznWeb.MentorPlugs do
  import Plug.Conn
  alias Tzn.Transizion
  require Logger

  def load_mentor_profile(conn, _) do
    mentor_profile = Transizion.get_mentor_profile(conn.assigns.current_user.id)

    conn |> assign(:current_mentor, mentor_profile)
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
