defmodule TznWeb.Admin.QuestionSetController do
  use TznWeb, :controller

  alias Tzn.Questionnaire

  def index(conn, _params) do
    sets = Questionnaire.list_question_sets()
    render(conn, "index.html", sets: sets)
  end

  def edit(conn, %{"id" => set_id}) do
    set = Questionnaire.get_question_set(set_id)
    questions = Questionnaire.list_questions_in_set(set)
    render(conn, "edit.html", set: set, questions: questions)
  end

  def move_down(conn, %{"question_id" => question_id, "question_set_id" => question_set_id}) do
    {_, message} =
      Questionnaire.move_question_down(
        String.to_integer(question_id),
        String.to_integer(question_set_id)
      )

    conn
    |> put_flash(:info, message)
    |> redirect(to: Routes.admin_question_set_path(conn, :edit, question_set_id))
  end

  def move_up(conn, %{"question_id" => question_id, "question_set_id" => question_set_id}) do
    {_, message} =
      Questionnaire.move_question_up(
        String.to_integer(question_id),
        String.to_integer(question_set_id)
      )

    conn
    |> put_flash(:info, message)
    |> redirect(to: Routes.admin_question_set_path(conn, :edit, question_set_id))
  end
end
