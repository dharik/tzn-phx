defmodule TznWeb.Admin.QuestionnaireController do
  use TznWeb, :controller

  alias Tzn.Repo
  alias Tzn.Questionnaire

  def edit(conn, %{"id" => id} = params) do
    questionnaire = Questionnaire.get_questionnaire_by_id(id, conn.assigns.current_user) |> Repo.preload(:snapshots)

    selected_snapshot =
      Tzn.Util.find_by_id(questionnaire.snapshots, params["version"]) || List.last(questionnaire.snapshots)

    questions = Questionnaire.ordered_questions_in_set(questionnaire.question_set)
    answers = Questionnaire.list_answers(questionnaire)

    render(conn, "edit.html",
      mentee: questionnaire.mentee,
      questions: questions,
      answers: answers,
      questionnaire: questionnaire,
      state_changeset: Questionnaire.Questionnaire.changeset(questionnaire),
      selected_snapshot: selected_snapshot,
      snapshots: questionnaire.snapshots
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
    |> redirect(to: Routes.admin_questionnaire_path(conn, :edit, questionnaire))
  end
end
