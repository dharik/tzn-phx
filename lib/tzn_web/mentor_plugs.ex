defmodule TznWeb.MentorPlugs do
  import Plug.Conn
  alias Tzn.Repo
  alias Tzn.Transizion

  def load_my_mentees(conn, _) do
    mentees =
      Transizion.list_mentees(%{mentor: conn.assigns.current_user})
      |> Repo.preload(:hour_counts)

    conn |> assign(:mentees, mentees)
  end

  def load_mentor_profile(conn, _) do
    mentor_profile = Transizion.get_current_mentor(conn.assigns.current_user.id)

    conn |> assign(:current_mentor, mentor_profile)
  end

  def ensure_mentor_profile(conn, _) do
    if conn.assigns.current_mentor do
      conn
    else
      conn |> halt
    end
  end
end
