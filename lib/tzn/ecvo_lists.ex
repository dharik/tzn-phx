defmodule Tzn.EcvoLists do
  import Ecto.Query
  alias Tzn.DB.Pod
  alias Tzn.Repo

  def only_ecvo_lists(questionnaires) do
    Enum.filter(questionnaires, &(&1.question_set.slug == "ec_vo_list"))
  end

  def ecvo_list_question_set do
    Tzn.Questionnaire.get_question_set_by_slug("ec_vo_list")
  end

  def access?(%Pod{ecvo_list_limit: limit}) do
    case limit do
      nil -> false
      0 -> false
      _ -> true
    end
  end

  def usage(%Pod{} = p) do
    used =
      p.questionnaires
      |> only_ecvo_lists()
      |> Enum.count()

    total = p.ecvo_list_limit || 0

    %{used: used, total: total}
  end

  def can_start_ecvo_list(%Pod{} = p) do
    lists = only_ecvo_lists(p.questionnaires)
    used = Enum.count(lists)
    total = p.ecvo_list_limit || 0
    Enum.all?(lists, fn q -> q.state == "complete" end) && total > used
  end

  def completed_ecvo_lists(%Pod{} = p) do
    p.questionnaires
    |> only_ecvo_lists()
    |> Enum.filter(&(&1.state == "complete"))
  end

  def current_ecvo_list(%Pod{} = p) do
    p.questionnaires
    |> only_ecvo_lists()
    |> Enum.reject(&(&1.state == "complete"))
    |> List.first()
  end

  def create_ecvo_list(%Pod{} = p, current_profile) do
    if q = current_ecvo_list(p) do
      {:in_progress, q}
    else
      ecvo_list_question_set = ecvo_list_question_set()
      questions = ecvo_list_question_set |> Ecto.assoc(:questions) |> Repo.all()
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
          question_set_id: ecvo_list_question_set.id,
          mentee_id: p.mentee_id,
          state: "needs_info",
          access_key: nil
        },
        current_profile
      )
    end
  end
end
