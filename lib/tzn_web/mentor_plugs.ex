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
end
