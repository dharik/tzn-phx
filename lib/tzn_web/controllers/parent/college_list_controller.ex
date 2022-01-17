defmodule TznWeb.Parent.CollegeListController do
  use TznWeb, :controller
  alias Tzn.Questionnaire

  def edit(conn, %{"access_key_short" => access_key}) do
    questionnaire =
      access_key
      |> ShortUUID.decode!()
      |> Questionnaire.get_questionnaire_by_access_key(conn.assigns.current_user)

    questions = Questionnaire.ordered_questions_in_set(questionnaire.question_set)
    answers = Questionnaire.list_answers(questionnaire)
    mentor = Tzn.Transizion.get_mentor(questionnaire.mentee)

    render(conn, "edit.html",
      questions: questions,
      answers: answers,
      mentor: mentor,
      mentee: questionnaire.mentee,
      access_key: ShortUUID.encode!(questionnaire.access_key),
      files: questionnaire.files
    )
  end

  def upload(conn, %{"access_key_short" => access_key, "attachment" => file}) do
    questionnaire =
      access_key
      |> ShortUUID.decode!()
      |> Questionnaire.get_questionnaire_by_access_key(conn.assigns.current_user)

    Questionnaire.attach_file(questionnaire, file, conn.assigns.current_user)

    conn
    |> put_flash(:info, "File Uploaded Successfully.")
    |> redirect(to: Routes.college_list_path(conn, :edit, access_key))
  end

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
end
