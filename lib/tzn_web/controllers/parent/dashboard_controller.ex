defmodule TznWeb.Parent.DashboardController do
  use TznWeb, :controller
  import TznWeb.ParentPlugs

  plug :ensure_parent_profile_and_mentees
  plug :load_questionnaires

  plug :put_layout, "parent.html"

  def show(conn, _params) do
    mentor_todos =
      conn.assigns.pod.todos
      |> Enum.reject(&(&1.deleted_at || &1.completed))
      |> Enum.filter(&(&1.assignee_type == "mentor"))
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})

    mentee_todos =
      conn.assigns.pod.todos
      |> Enum.reject(&(&1.deleted_at || &1.completed))
      |> Enum.filter(&(&1.assignee_type == "mentee"))
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})

    parent_todos =
      conn.assigns.pod.todos
      |> Enum.reject(&(&1.deleted_at || &1.completed))
      |> Enum.filter(&(&1.assignee_type == "parent"))
      |> Enum.sort_by(& &1.inserted_at, {:desc, NaiveDateTime})

    completed =
      conn.assigns.pod.todos
      |> Enum.reject(& &1.deleted_at)
      |> Enum.filter(& &1.completed)
      |> Enum.sort_by(& &1.completed_changed_at, {:desc, NaiveDateTime})
      |> Enum.take(5)

    conn
    |> render("show.html",
      mentor_todos: mentor_todos,
      mentee_todos: mentee_todos,
      parent_todos: parent_todos,
      completed_todos: completed
    )
  end
end
