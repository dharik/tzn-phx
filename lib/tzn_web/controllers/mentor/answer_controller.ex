defmodule TznWeb.Mentor.AnswerController do
  use TznWeb, :controller

  def create_or_update(conn, %{
        "question_id" => question_id,
        "mentee_id" => mentee_id,
        "from_pod" => from_pod
      }) do
    question = Tzn.Questionnaire.get_question(question_id)
    mentee = Tzn.Transizion.get_mentee(mentee_id)

    case Tzn.Questionnaire.set_pod_answer(
           question,
           mentee,
           from_pod,
           conn.assigns.current_user
         ) do
      {:ok, answer} -> json(conn, %{value: answer.from_pod})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end

  def create_or_update(conn, %{
        "question_id" => question_id,
        "mentee_id" => mentee_id,
        "internal" => internal_response
      }) do
    question = Tzn.Questionnaire.get_question(question_id)
    mentee = Tzn.Transizion.get_mentee(mentee_id)

    case Tzn.Questionnaire.set_internal_note(
           question,
           mentee,
           internal_response,
           conn.assigns.current_user
         ) do
      {:ok, answer} -> json(conn, %{value: answer.internal})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end
end
