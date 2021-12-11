defmodule TznWeb.Admin.QuestionSetController do
  use TznWeb, :controller

  alias Tzn.Questionnaire

  def edit(conn, %{"id" => set_id}) do
    set = Questionnaire.get_question_set(set_id)
    questions = Questionnaire.ordered_questions_in_set(set)
    render(conn, "edit.html", set: set, questions: questions)
  end

  def move_down(conn, %{"question_id" => question_id, "question_set_id" => question_set_id}) do
    question = Questionnaire.get_question(question_id)
    set = Questionnaire.get_question_set(question_set_id)

    {_, message} = Questionnaire.move_question_down(question, set, conn.assigns.current_user)

    conn
    |> put_flash(:info, message)
    |> redirect(to: Routes.admin_question_set_path(conn, :edit, question_set_id))
  end

  def move_up(conn, %{"question_id" => question_id, "question_set_id" => question_set_id}) do
    question = Questionnaire.get_question(question_id)
    set = Questionnaire.get_question_set(question_set_id)

    {_, message} = Questionnaire.move_question_up(question, set, conn.assigns.current_user)

    conn
    |> put_flash(:info, message)
    |> redirect(to: Routes.admin_question_set_path(conn, :edit, question_set_id))
  end
end
