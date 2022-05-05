defmodule TznWeb.Parent.ECVOListController do
  use TznWeb, :controller
  alias Tzn.Questionnaire

  def edit(conn, %{"access_key_short" => access_key}) do
    questionnaire =
      access_key
      |> ShortUUID.decode!()
      |> Questionnaire.get_questionnaire_by_access_key(conn.assigns.current_user)

    questions = Questionnaire.ordered_questions_in_set(questionnaire.question_set)
    answers = Questionnaire.list_answers(questionnaire)

    render(conn, "edit.html",
      questions: questions,
      answers: answers,
      mentee: questionnaire.mentee,
      access_key: ShortUUID.encode!(questionnaire.access_key),
      files: questionnaire.files
    )
  end
end
