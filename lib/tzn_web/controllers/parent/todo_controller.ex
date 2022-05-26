defmodule TznWeb.Parent.TodoController do
  use TznWeb, :controller
  import TznWeb.ParentPlugs

  plug :ensure_parent_profile_and_mentees

  def update(conn, %{"id" => pod_todo_id}) do
    todo = Tzn.Pods.get_todo(pod_todo_id)

    unless todo.pod_id in Enum.map(conn.assigns.pods, & &1.id) do
      raise Tzn.Policy.UnauthorizedError
    end

    Tzn.Pods.update_todo_complete_state(todo, %{completed: !todo.completed, completed_changed_by: "parent"})

    redirect(conn, to: Routes.parent_dashboard_path(conn, :show))
  end
end
