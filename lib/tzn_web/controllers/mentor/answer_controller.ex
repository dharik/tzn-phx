defmodule TznWeb.Mentor.AnswerController do
  use TznWeb, :controller

  def create_or_update(conn, %{
        "question_id" => question_id,
        "mentee_id" => mentee_id,
        "response" => response
      }) do
    question = Tzn.Questionnaire.get_question(question_id)
    mentee = Tzn.Transizion.get_mentee(mentee_id)

    case Tzn.Questionnaire.set_pod_answer(
           question,
           mentee,
           response,
           conn.assigns.current_user
         ) do
      {:ok, answer} -> json(conn, %{value: answer.from_pod})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end
end
