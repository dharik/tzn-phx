defmodule TznWeb.Mentor.ECVOListController do
  use TznWeb, :controller
  alias Tzn.Questionnaire
  alias Tzn.Repo

  # For the specialists
  def index(conn, params) do
    set_id = Tzn.EcvoLists.ecvo_list_question_set().id

    questionnaires =
      Questionnaire.list_questionnaires(conn.assigns.current_user)
      |> Enum.filter(&(&1.question_set_id == set_id))

    render(conn, "index.html", lists: questionnaires, include_hidden: !!params["include_hidden"])
  end

  def show(conn, %{"id" => id} = params) do
    questionnaire =
      Questionnaire.get_questionnaire_by_id(id, conn.assigns.current_user)
      |> Repo.preload(:snapshots)

    selected_snapshot =
      Tzn.Util.find_by_id(questionnaire.snapshots, params["version"]) ||
        List.last(questionnaire.snapshots)

    if is_nil(selected_snapshot) do
      raise "No snapshot found"
    end

    conn |> render("show.html", questionnaire: questionnaire, snapshot: selected_snapshot)
  end

  def edit(conn, %{"id" => id}) do
    questionnaire = Questionnaire.get_questionnaire_by_id(id, conn.assigns.current_user)
    questions = Questionnaire.ordered_questions_in_set(questionnaire.question_set)
    answers = Questionnaire.list_answers(questionnaire)

    is_my_mentee =
      Tzn.Pods.list_pods(conn.assigns.current_mentor)
      |> Enum.filter(fn p -> p.mentee_id == questionnaire.mentee_id end)
      |> Enum.any?()

    if questionnaire.state == "complete" && !conn.assigns.current_mentor.ecvo_list_specialty do
      redirect(conn, to: Routes.mentor_ecvo_list_path(conn, :show, questionnaire))
    else
      render(conn, "edit.html",
        mentee: questionnaire.mentee,
        questions: questions,
        answers: answers,
        questionnaire: questionnaire,
        state_changeset: Questionnaire.Questionnaire.changeset(questionnaire),
        is_my_mentee: is_my_mentee
      )
    end
  end

  def update(conn, %{"id" => id, "questionnaire" => %{"state" => new_state}}) do
    questionnaire = Questionnaire.get_questionnaire_by_id(id, conn.assigns.current_user)

    Tzn.Questionnaire.update_questionnare_state(
      questionnaire,
      new_state,
      conn.assigns.current_user
    )

    conn
    |> redirect(to: Routes.mentor_ecvo_list_path(conn, :edit, questionnaire))
  end

  def update(conn, %{"id" => id, "body" => body}) do
    questionnaire = Questionnaire.get_questionnaire_by_id(id, conn.assigns.current_user)

    Tzn.ResearchListEmailer.send_parent_email(questionnaire, body, conn.assigns.current_mentor)

    conn
    |> redirect(to: Routes.mentor_ecvo_list_path(conn, :edit, questionnaire))
  end

  def update(conn, %{"id" => id, "attachment" => file}) do
    questionnaire = Questionnaire.get_questionnaire_by_id(id, conn.assigns.current_user)

    Questionnaire.attach_file(questionnaire, file, conn.assigns.current_user)

    conn
    |> redirect(to: Routes.mentor_ecvo_list_path(conn, :edit, questionnaire))
  end

  def create(conn, %{"pod_id" => pod_id}) do
    pod = Tzn.Pods.get_pod!(pod_id)

    case Tzn.EcvoLists.create_ecvo_list(pod, conn.assigns.current_user) do
      {:ok, questionnaire} ->
        conn
        |> redirect(to: Routes.mentor_ecvo_list_path(conn, :edit, questionnaire))

      {:in_progress, questionnaire} ->
        conn
        |> redirect(to: Routes.mentor_ecvo_list_path(conn, :edit, questionnaire))

      {:error, _changeset} ->
        conn
        |> redirect(to: Routes.mentor_pod_path(conn, :show, pod))
    end
  end
end
