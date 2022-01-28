defmodule TznWeb.Parent.QuestionnaireController do
  use TznWeb, :controller
  alias Tzn.Questionnaire

  def create_or_update_answer(conn, %{
        "access_key_short" => access_key,
        "question_id" => question_id,
        "response" => response
      }) do
    questionnaire =
      access_key
      |> ShortUUID.decode!()
      |> Questionnaire.get_questionnaire_by_access_key(conn.assigns.current_user)

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

  def upload(conn, %{"access_key_short" => access_key, "attachment" => file}) do
    questionnaire =
      access_key
      |> ShortUUID.decode!()
      |> Questionnaire.get_questionnaire_by_access_key(conn.assigns.current_user)

    Questionnaire.attach_file(questionnaire, file, conn.assigns.current_user)

    conn
    |> put_flash(:info, "File Uploaded Successfully.")
    |> redirect(to: edit_path(conn, questionnaire))
  end

  def edit_path(conn, questionnaire) do
    case questionnaire.question_set.slug do
      "college_list" ->
        Routes.college_list_path(conn, :edit, questionnaire.access_key |> ShortUUID.encode!())

      "ec_vo_list" ->
        Routes.ecvo_list_path(conn, :edit, questionnaire.access_key |> ShortUUID.encode!())

      "scholarship_list" ->
        Routes.scholarship_list_path(conn, :edit, questionnaire.access_key |> ShortUUID.encode!())
    end
  end
end
