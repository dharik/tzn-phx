defmodule TznWeb.MentorQuestionnaireAnswers do
  use Phoenix.LiveView
  use Phoenix.HTML
  import TznWeb.ErrorHelpers

  def mount(_params, %{"questionnaire_id" => questionnaire_id, "current_user_id" => current_user_id}, socket) do
    user = Tzn.Users.get_user!(current_user_id)
    mentor = Tzn.Transizion.get_mentor(user)

    # Todo: Confirm current_user can edit this questionnaire

    questionnaire = Tzn.Questionnaire.get_questionnaire_by_id(questionnaire_id, user)
    questions = Tzn.Questionnaire.ordered_questions_in_set(questionnaire.question_set)

    is_my_mentee = Tzn.Pods.list_pods(mentor)
      |> Enum.filter(fn p -> p.mentee_id == questionnaire.mentee_id end)
      |> Enum.any?()

    {:ok,
      socket
      |> assign(:current_user, user)
      |> assign(:current_mentor, mentor)
      |> assign(:is_my_mentee, is_my_mentee)
      |> assign(:questionnaire, questionnaire)
      |> assign(:questions, questions)
      |> assign(:answers_updated_this_session, MapSet.new())
      |> build_question_to_answer_map()
    }
  end

  def build_question_to_answer_map(socket) do
    questions = socket.assigns.questions
    answers = Tzn.Questionnaire.list_answers(socket.assigns.questionnaire)

    question_to_answer_map = questions
      |> Enum.map(fn q ->
        answer = Enum.find(answers, fn a -> a.question_id == q.id end)
        {q.id, answer}
      end)
      |> Enum.reject(fn {question_id, answer} -> is_nil(answer) end)
      |> Map.new()

    assign(socket, :question_to_answer_map, question_to_answer_map)
  end

  def handle_event("change_answer", %{"answer" => %{"from_pod" => pod_response, "question_id" => question_id}}, socket) do
    question_id = String.to_integer(question_id)
    question = socket.assigns.questions |> Tzn.Util.find_by_id(question_id)

    {:ok, answer} = Tzn.Questionnaire.set_pod_answer(question, socket.assigns.questionnaire.mentee, pod_response, socket.assigns.current_user)

    {
      :noreply,
      socket
        |> assign(:question_to_answer_map, Map.put(socket.assigns.question_to_answer_map, question.id, answer))
        |> assign(:answers_updated_this_session, MapSet.put(socket.assigns.answers_updated_this_session, "#{answer.id}/from_pod"))
    }
  end

  def handle_event("change_answer", %{"answer" => %{"internal" => interal_response, "question_id" => question_id}}, socket) do
    question_id = String.to_integer(question_id)
    question = socket.assigns.questions |> Tzn.Util.find_by_id(question_id)

    {:ok, answer} = Tzn.Questionnaire.set_internal_note(question, socket.assigns.questionnaire.mentee, interal_response, socket.assigns.current_user)

    {
      :noreply,
      socket
        |> assign(:question_to_answer_map, Map.put(socket.assigns.question_to_answer_map, question.id, answer))
        |> assign(:answers_updated_this_session, MapSet.put(socket.assigns.answers_updated_this_session, "#{answer.id}/internal"))
    }
  end

  def handle_event("confirm_answer", %{"id" => answer_id}, socket) do
    {:ok, answer} = answer_id |> Tzn.Questionnaire.get_answer() |> Tzn.Questionnaire.touch_answer()

    {
      :noreply,
      socket
        |> assign(:question_to_answer_map, Map.put(socket.assigns.question_to_answer_map, answer.question_id, answer))
    }
  end

end
