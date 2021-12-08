defmodule TznWeb.MentorPlugs do
  import Plug.Conn
  alias Tzn.Repo
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

  # These should all be one method if they have dependencies on each other
  def load_my_mentees(conn, _) do
    mentees =
      Transizion.list_mentees(%{mentor: conn.assigns.current_mentor})
      |> Repo.preload(:hour_counts)
      |> Enum.reject(fn m -> m.archived end)

    conn |> assign(:mentees, mentees)
  end
end
