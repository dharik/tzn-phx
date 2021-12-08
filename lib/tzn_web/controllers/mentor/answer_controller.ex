defmodule TznWeb.Mentor.AnswerController do
  use TznWeb, :controller
  alias Tzn.Questionnaire
  require Logger
  require IEx

  def create_or_update(conn, %{
        "question_id" => question_id,
        "mentee_id" => mentee_id,
        "response" => from_pod
      }) do
    question = Tzn.Questionnaire.get_question(question_id)
    mentee = Tzn.Transizion.get_mentee(mentee_id)

    case Tzn.Questionnaire.create_or_update_answer(
           question,
           mentee,
           %{
             from_pod: from_pod
           }
         ) do
      {:ok, answer} -> json(conn, %{value: answer.from_pod})
      {:error, changeset} -> conn |> send_resp(403, "Error" <> changeset.errors)
    end
  end
end
