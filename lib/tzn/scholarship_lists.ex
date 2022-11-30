defmodule Tzn.ScholarshipLists do
  import Ecto.Query
  alias Tzn.DB.Pod
  alias Tzn.Repo

  def only_scholarship_lists(questionnaires) do
    Enum.filter(questionnaires, &(&1.question_set.slug == "scholarship_list"))
  end

  def scholarship_list_question_set do
    Tzn.Questionnaire.get_question_set_by_slug("scholarship_list")
  end

  def access?(%Pod{scholarship_list_limit: limit}) do
    case limit do
      nil -> false
      0 -> false
      _ -> true
    end
  end

  def usage(%Pod{} = p) do
    used =
      p.questionnaires
      |> only_scholarship_lists()
      |> Enum.count()

    total = p.scholarship_list_limit || 0

    %{used: used, total: total}
  end

  def can_start_scholarship_list(%Pod{} = p) do
    lists = only_scholarship_lists(p.questionnaires)
    used = Enum.count(lists)
    total = p.scholarship_list_limit || 0
    Enum.all?(lists, fn q -> q.state == "complete" end) && total > used
  end

  def completed_scholarship_lists(%Pod{} = p) do
    p.questionnaires
    |> only_scholarship_lists()
    |> Enum.filter(&(&1.state == "complete"))
  end

  def current_scholarship_list(%Pod{} = p) do
    p.questionnaires
    |> only_scholarship_lists()
    |> Enum.reject(&(&1.state == "complete"))
    |> List.first()
  end

  def create_scholarship_list(%Pod{} = p, current_profile) do
    if q = current_scholarship_list(p) do
      {:in_progress, q}
    else
      scholarship_list_question_set = scholarship_list_question_set()
      questions = scholarship_list_question_set |> Ecto.assoc(:questions) |> Repo.all()
      question_ids = Tzn.Util.map_ids(questions)

      # Wipe pod answers that are impacted by the question having changed
      from(
        a in Tzn.Questionnaire.Answer,
        where: a.question_id in ^question_ids,
        where: a.mentee_id == ^p.mentee_id,
        join: q in assoc(a, :question),
        where: q.updated_at > a.updated_at
      )
      |> Repo.update_all(set: [from_pod: ""])

      # Wipe all the parent answers because we force those to be re-answered
      from(a in Tzn.Questionnaire.Answer,
        where: a.question_id in ^question_ids,
        where: a.mentee_id == ^p.mentee_id
      )
      |> Repo.update_all(set: [from_parent: ""])

      # Create the new questionnaire
      Tzn.Questionnaire.create_questionnaire(
        %{
          question_set_id: scholarship_list_question_set.id,
          mentee_id: p.mentee_id,
          state: "needs_info",
          access_key: nil
        },
        current_profile
      )
    end
  end
end
