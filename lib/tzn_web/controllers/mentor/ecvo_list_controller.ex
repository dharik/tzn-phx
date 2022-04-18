defmodule TznWeb.Mentor.ECVOListController do
  use TznWeb, :controller
  alias Tzn.Questionnaire

  # For the specialists
  def index(conn, params) do
    set_id = Tzn.Questionnaire.ecvo_list_question_set().id

    questionnaires =
      Questionnaire.list_questionnaires(conn.assigns.current_user)
      |> Enum.filter(&(&1.question_set_id == set_id))

    render(conn, "index.html", lists: questionnaires, include_hidden: !!params["include_hidden"])
  end

  def edit(conn, %{"id" => id}) do
    questionnaire = Questionnaire.get_questionnaire_by_id(id, conn.assigns.current_user)
    questions = Questionnaire.ordered_questions_in_set(questionnaire.question_set)
    answers = Questionnaire.list_answers(questionnaire)
    is_my_mentee = questionnaire.mentee.mentor_id == conn.assigns.current_mentor.id

    render(conn, "edit.html",
      mentee: questionnaire.mentee,
      questions: questions,
      answers: answers,
      questionnaire: questionnaire,
      state_changeset: Questionnaire.Questionnaire.changeset(questionnaire),
      is_my_mentee: is_my_mentee
    )
  end

  def update(conn, %{"id" => id, "questionnaire" => %{"state" => new_state}}) do
    questionnaire = Questionnaire.get_questionnaire_by_id(id, conn.assigns.current_user)

    Tzn.Questionnaire.update_questionnare_state(
      questionnaire,
      new_state,
      conn.assigns.current_user
    )

    conn
    |> put_flash(:info, "Updated.")
    |> redirect(to: Routes.mentor_ecvo_list_path(conn, :edit, questionnaire))
  end

  def update(conn, %{"id" => id, "body" => body}) do
    questionnaire = Questionnaire.get_questionnaire_by_id(id, conn.assigns.current_user)

    Tzn.Questionnaire.send_parent_email(questionnaire, body)

    conn
    |> redirect(to: Routes.mentor_ecvo_list_path(conn, :edit, questionnaire))
  end

  def update(conn, %{"id" => id, "attachment" => file}) do
    questionnaire = Questionnaire.get_questionnaire_by_id(id, conn.assigns.current_user)

    Questionnaire.attach_file(questionnaire, file, conn.assigns.current_user)

    conn
    |> put_flash(:info, "File Uploaded Successfully")
    |> redirect(to: Routes.mentor_ecvo_list_path(conn, :edit, questionnaire))
  end

  def create(conn, %{"mentee_id" => mentee_id}) do
    mentee = Tzn.Mentee.get_mentee!(mentee_id)

    case Questionnaire.create_questionnaire(
           %{
             question_set_id: Tzn.Questionnaire.ecvo_list_question_set().id,
             mentee_id: mentee.id,
             state: "needs_info",
             access_key: nil
           },
           conn.assigns.current_user
         ) do
      {:ok, questionnaire} ->
        conn
        |> redirect(to: Routes.mentor_ecvo_list_path(conn, :edit, questionnaire))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.mentor_mentee_path(conn, :show, mentee))
    end
  end
end
