defmodule TznWeb.Mentor.CollegeListController do
  use TznWeb, :controller
  alias Tzn.Questionnaire

  def index(conn, _) do
    questionnaires = Questionnaire.list_questionnaires()
    # TODO: Filter down to just college list

    render(conn, "index.html", lists: questionnaires)
  end

  def edit(conn, %{"id" => id}) do
    questionnaire = Questionnaire.get_questionnaire_by_id(id)
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

  # Update state
  # Only if mentee in current_mentor.mentees OR current_mentor.college_list_specialty
  def update(conn, %{"id" => id, "questionnaire" => %{"state" => new_state}}) do
    questionnaire = Questionnaire.get_questionnaire_by_id(id)

    Tzn.Questionnaire.update_questionnare_state(
      questionnaire,
      new_state,
      conn.assigns.current_mentor
    )

    conn |> put_flash(:info, "Updated.") |> redirect(to: Routes.mentor_college_list_path(conn, :edit, questionnaire))
  end

  def create(conn, %{"mentee_id" => mentee_id}) do
    mentee = Tzn.Transizion.get_mentee!(mentee_id)

    case Questionnaire.create_questionnaire(%{
           question_set_id: Tzn.Questionnaire.college_list_question_set().id,
           mentee_id: mentee.id,
           state: "needs_info",
           access_key: nil
         }) do
      {:ok, questionnaire} ->
        conn
        |> redirect(to: Routes.mentor_college_list_path(conn, :edit, questionnaire))

      {:error, _changeset} ->
        conn
        |> put_flash(:error, "Something went wrong")
        |> redirect(to: Routes.mentor_mentee_path(conn, :show, mentee))
    end
  end
end
