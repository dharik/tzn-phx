defmodule TznWeb.ParentPlugs do
  import Plug.Conn
  import Phoenix.Controller
  require Logger
  alias TznWeb.Router.Helpers, as: Routes

  def ensure_parent_profile_and_mentees(conn, _) do
    with parent_profile <- Tzn.Profiles.get_parent(conn.assigns.current_user),
         mentees = Tzn.Profiles.list_mentees(parent_profile),
         pods = Enum.flat_map(mentees, fn mentee -> Tzn.Pods.list_pods(mentee) end),
         true <- Enum.any?(pods) do
      conn
      |> assign(:parent_profile, parent_profile)
      |> assign(:mentees, mentees)
      |> assign(:pods, pods)
      |> load_pod()
    else
      _ ->
        Logger.error("No parent profile or mentees")
        conn |> redirect(to: Routes.entry_path(conn, :launch_app)) |> halt()
    end
  end

  defp load_pod(conn) do
    pod_id =
      if is_binary(conn.params["pod"]) do
        String.to_integer(conn.params["pod"])
      else
        get_session(conn, "selected_pod_id")
      end

    pod = Enum.find(conn.assigns.pods, List.first(conn.assigns.pods), &(&1.id == pod_id))

    IO.inspect(pod)
    conn |> assign(:pod, pod) |> put_session("selected_pod_id", pod.id)
  end

  def load_questionnaires(conn, _) do
    if conn.assigns[:pod] do
      assign(conn, :questionnaires, Tzn.Questionnaire.list_questionnaires(conn.assigns[:pod].mentee))
    else
      conn
    end
  end
end
