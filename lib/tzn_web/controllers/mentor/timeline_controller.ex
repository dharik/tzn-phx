defmodule TznWeb.Mentor.TimelineController do
  use TznWeb, :controller

  def index(conn, %{"pod_id" => pod_id}) do
    pod = Tzn.Pods.get_pod!(pod_id)

    unless pod.id in Tzn.Util.map_ids(conn.assigns.pods) do
      raise "Unauthorized"
    end

    timeline = Tzn.Timelines.get_or_create_timeline(pod)

    render(conn, "index.html", timeline: timeline, pod: pod)
  end

  def index(conn, _params) do
    render(conn, "no_mentee_index.html")
  end
end
