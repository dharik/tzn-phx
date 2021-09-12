defmodule TznWeb.Admin.CollegeListController do
  use TznWeb, :controller

  # UI to modify list of questions
  def index(conn, _) do
    render(conn, :index)
  end

  # api
  def update_questions(conn, %{questions: questions}) do
    {:ok, _} = Tzn.CollegeList.set_college_list_questions(questions)
    list_questions(conn, nil)
  end

  # api
  def list_questions(conn, _) do
    json(
      conn,
      Tzn.CollegeList.list_questions()
      |> Enum.map(fn q ->
        %{
          id: q.id,
          question: q.question,
          help: q.help,
          placeholder: q.placeholder,
          display_order: q.display_order,
          active: q.active,
          parent_answer_required: q.parent_answer_required
        }
      end)
    )
  end
end
