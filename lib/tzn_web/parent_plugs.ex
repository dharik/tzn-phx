defmodule TznWeb.ParentPlugs do
  import Plug.Conn
  import Phoenix.Controller
  require Logger
  alias TznWeb.Router.Helpers, as: Routes

  def ensure_parent_profile_and_mentees(conn, _) do
    with parent_profile <- Tzn.Profiles.get_parent(conn.assigns.current_user),
         mentees = Tzn.Profiles.list_mentees(parent_profile),
         true <- Enum.any?(mentees) do
      conn |> assign(:parent_profile, parent_profile) |> assign(:mentees, mentees)
    else
      _ ->
        Logger.error("No parent profile or mentees")
        conn |> redirect(to: Routes.entry_path(conn, :launch_app)) |> halt()
    end
  end

  def load_mentee(conn, _) do
    conn |> load_mentee_from_params() |> load_mentee_from_session() |> load_questionnaires()
  end

  def load_mentee_from_params(conn) do
    if conn.params["mentee"] do
      mentee = Tzn.Transizion.get_mentee!(conn.params["mentee"])

      unless mentee in conn.assigns.mentees do
        raise Tzn.Policy.UnauthorizedError
      end

      conn
      |> put_session("selected_mentee_id", mentee.id)
      |> assign(:mentee, mentee)
    else
      conn
    end
  end

  def load_mentee_from_session(conn) do
    mentee_id_from_session = get_session(conn, "selected_mentee_id")
    mentees = conn.assigns[:mentees]

    mentee =
      if mentee_id_from_session && mentee_id_from_session in Enum.map(mentees, & &1.id) do
        Tzn.Transizion.get_mentee!(mentee_id_from_session)
      else
        hd(mentees)
      end

    conn |> assign(:mentee, mentee)
  end

  def load_questionnaires(conn) do
    if conn.assigns[:mentee] do
      assign(conn, :questionnaires, Tzn.Questionnaire.list_questionnaires(conn.assigns[:mentee]))
    else
      conn
    end
  end
end
