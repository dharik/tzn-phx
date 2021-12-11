defmodule TznWeb.Parent.CollegeListController do
  use TznWeb, :controller
  alias Tzn.Questionnaire

  def edit(conn, %{"access_key" => access_key}) do
    questionnaire = Questionnaire.get_questionnaire_by_access_key(access_key)
    questions = Questionnaire.ordered_questions_in_set(questionnaire.question_set)
    answers = Questionnaire.list_answers(questionnaire)
    mentor = Tzn.Transizion.get_mentor_profile(questionnaire.mentee)

    render(conn, "edit.html",
      questions: questions,
      answers: answers,
      mentor: mentor,
      mentee: questionnaire.mentee,
      access_key: questionnaire.access_key
    )
  end

  def create_or_update_answer(conn, %{
        "access_key" => access_key,
        "question_id" => question_id,
        "response" => response
      }) do
    questionnaire = Tzn.Questionnaire.get_questionnaire_by_access_key(access_key)
    mentee = questionnaire.mentee
    question = Tzn.Questionnaire.get_question(question_id)

    case Tzn.Questionnaire.set_parent_answer(
           question,
           mentee,
           response
         ) do
      {:ok, answer} -> json(conn, %{value: answer.from_parent})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end
end
