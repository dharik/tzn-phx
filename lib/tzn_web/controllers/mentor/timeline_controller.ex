defmodule TznWeb.Mentor.TimelineController do
  use TznWeb, :controller

  def index(conn, %{"pod_id" => pod_id}) do
    pod = Tzn.Pods.get_pod!(pod_id)
    unless pod.id in Tzn.Util.map_ids(conn.assigns.pods) do
      raise "Unauthorized"
    end

    timeline =
      if pod.timeline do
        Tzn.Timelines.get_timeline(pod.timeline.access_key)
      else
        {:ok, t} = Tzn.Timelines.create_timeline(pod)
        Tzn.Pods.update_pod(pod, %{timeline_id: t.id}, conn.assigns.current_user)
        t
      end

    render(conn, "index.html", timeline: timeline, pod: pod)
  end

  def index(conn, _params) do
    render(conn, "no_mentee_index.html")
  end
end
