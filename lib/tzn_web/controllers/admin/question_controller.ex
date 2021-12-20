defmodule TznWeb.Admin.QuestionController do
  use TznWeb, :controller

  alias Tzn.Questionnaire

  def index(conn, _params) do
    questions = Questionnaire.list_questions(conn.assigns.current_user)
    sets = Questionnaire.list_question_sets()
    questionnaires = Questionnaire.list_questionnaires(conn.assigns.current_user)
    render(conn, "index.html", questions: questions, question_sets: sets, questionnaires: questionnaires)
  end

  def edit(conn, %{"id" => id}) do
    question = Questionnaire.get_question(id)
    changeset = Questionnaire.change_question(question)
    question_sets = Questionnaire.list_question_sets()

    render(conn, "edit.html",
      changeset: changeset,
      question: question,
      question_sets: question_sets,
      selected_sets: question.question_sets
    )
  end

  def new(conn, _params) do
    changeset = Questionnaire.change_question(%Questionnaire.Question{question_sets: []})
    question_sets = Questionnaire.list_question_sets()
    render(conn, "new.html", changeset: changeset, question_sets: question_sets, selected_sets: [])
  end

  def create(conn, %{"question" => question_params}) do
    case Questionnaire.create_question(question_params, conn.assigns.current_user) do
      {:ok, _question} ->
        conn
        |> put_flash(:info, "Question created successfully.")
        |> redirect(to: Routes.admin_question_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        question_sets = Questionnaire.list_question_sets()
        selected_sets = Questionnaire.list_question_sets(question_params["question_sets"])
        render(conn, "new.html", changeset: changeset, question_sets: question_sets, selected_sets: selected_sets)
    end
  end

  def update(conn, %{"id" => id, "question" => question_params}) do
    question = Questionnaire.get_question(id)

    case Questionnaire.update_question(question, question_params, conn.assigns.current_user) do
      {:ok, _} ->
        conn
        |> put_flash(:info, "Question updated successfully.")
        |> redirect(to: Routes.admin_question_path(conn, :index))

      {:error, %Ecto.Changeset{} = changeset} ->
        question_sets = Questionnaire.list_question_sets()
        selected_sets = question.selected_sets

        render(conn, "edit.html",
          question: question,
          changeset: changeset,
          question_sets: question_sets,
          selected_sets: question.selected_sets
        )
    end
  end
end
