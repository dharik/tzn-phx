defmodule TznWeb.Parent.CollegeListController do
  use TznWeb, :controller

  def edit(conn, %{"access_key" => access_key}) do
    college_list =
      Tzn.CollegeList.get_college_list!(%{access_key: access_key})
      |> Tzn.Repo.preload(:college_list_answers)

    questions = Tzn.CollegeList.list_active_questions()

    render(conn, "edit.html", college_list: college_list, questions: questions)
  end
end
