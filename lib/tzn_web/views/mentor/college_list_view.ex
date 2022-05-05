defmodule TznWeb.Mentor.CollegeListView do
  use TznWeb, :view
  alias Tzn.Questionnaire.Questionnaire

  @doc """
  Prioritize questionnaires by action/attention
  """
  def order_by_state(questionnaires) do
    Enum.sort_by(questionnaires, fn q ->
      case q.state do
        "specialist" -> 1
        "ready_for_specialist" -> 2
        "designer" -> 3
        "needs_info" -> 4
        "complete" -> 5
      end
    end)
  end

  def only_hidden(questionnaires) do
    Enum.filter(questionnaires, fn q ->
      q.state == "needs_info" || q.state == "complete"
    end)
  end

  def only_shown(questionnaires) do
    Enum.reject(questionnaires, fn q ->
      q.state == "needs_info" || q.state == "complete"
    end)
  end

  def mentor_name(pods) do
    pods
    |> Enum.map(& &1.mentor)
    |> Enum.reject(&is_nil/1)
    |> Enum.map(& &1.name)
    |> Enum.join(", ")
  end

  @doc """
  returns :email_not_sent | :in_grace_period | :past_grace_period | :opened
  """
  def parent_state(%Questionnaire{} = q) do
    cond do
      !q.parent_email_sent_at ->
        :email_not_sent

      q.access_key_used_at ->
        :opened

      Tzn.Util.within_n_days_ago(q.parent_email_sent_at, 3) ->
        :in_grace_period

      true ->
        :past_grace_period
    end
  end
end
