defmodule TznWeb.Parent.CollegeListAnswerController do
  use TznWeb, :controller

  # post /college_list/answer -> json rendering the 
  # inputs: college list access_key, question id, answer id (number | null), answer text
  # outputs: success: boolean, error: string, answer id: numeric
  def create_or_update(conn, %{"access_key": access_key}) do
    college_list =
      Tzn.CollegeList.get_college_list!(%{access_key: access_key})
      |> Tzn.Repo.preload(:college_list_answers)

    questions = Tzn.CollegeList.list_active_questions()

    render(conn, "create_or_update.json", college_list: college_list, answer: "answer todo")
  end
end
