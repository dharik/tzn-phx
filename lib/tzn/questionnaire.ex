defmodule Tzn.Questionnaire do
  alias Tzn.Repo
  alias Tzn.Questionnaire.Question
  alias Tzn.Questionnaire.QuestionSet
  alias Tzn.Questionnaire.QuestionSetQuestion
  alias Tzn.Questionnaire.Questionnaire
  alias Tzn.Questionnaire.Answer
  alias Tzn.Transizion.Mentee

  import Ecto.Query

  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end

  def create_question(attrs \\ %{}) do
    question_sets = list_question_sets(attrs["question_sets"])
    Enum.each(question_sets, fn s -> rewrite_display_orders(s.id) end)

    %Question{}
    |> Question.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:question_sets, question_sets)
    |> Repo.insert()
  end

  def update_question(%Question{} = question, attrs) do
    question_sets = list_question_sets(attrs["question_sets"])
    Enum.each(question_sets, fn s -> rewrite_display_orders(s.id) end)

    question
    |> Question.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:question_sets, question_sets)
    |> Repo.update()
  end

  def list_questions() do
    Question |> order_by(asc: :id) |> Repo.all() |> Repo.preload(:question_sets)
  end

  def get_question(id) do
    Repo.get(Question, id) |> Repo.preload(:question_sets)
  end

  def get_question_set(id) do
    Repo.get(QuestionSet, id)
  end

  def get_question_set_by_slug(slug) do
    Repo.get_by(QuestionSet, slug: slug)
  end

  def college_list_question_set do
    get_question_set_by_slug("college_list")
  end

  # Lists question in set *in order*
  def ordered_questions_in_set(question_set) do
    Repo.all(
      from(qsq in QuestionSetQuestion,
        where: qsq.question_set_id == ^question_set.id,
        order_by: [asc: qsq.display_order],
        join: q in Question,
        on: q.id == qsq.question_id,
        select: q
      )
    )
  end

  def list_question_sets(nil), do: []

  def list_question_sets(ids) do
    Repo.all(
      from(qs in QuestionSet,
        where: qs.id in ^ids,
        order_by: [asc: qs.name]
      )
    )
  end

  def list_question_sets do
    QuestionSet |> order_by(asc: :name) |> Repo.all()
  end

  defp rewrite_display_orders(set_id) do
    Repo.all(
      from(qsq in QuestionSetQuestion,
        where: qsq.question_set_id == ^set_id,
        order_by: [asc: qsq.display_order]
      )
    )
    |> Enum.with_index()
    |> Enum.each(fn {j, index} ->
      Repo.update(QuestionSetQuestion.changeset(j, %{display_order: index + 1}))
    end)
  end

  def move_question_down(%Question{} = q, %QuestionSet{} = s) do
    next_question =
      ordered_questions_in_set(s)
      |> Enum.reverse()
      |> Enum.take_while(fn ordered_question -> q.id !== ordered_question.id end)
      |> List.last()

    if next_question do
      swap_questions_in_set(q, next_question, s)
      {:ok, "Moved down"}
    else
      {:error, "It's already the last question in the list"}
    end
  end

  def move_question_up(%Question{} = q, %QuestionSet{} = s) do
    previous_question =
      ordered_questions_in_set(s)
      |> Enum.take_while(fn ordered_question -> q.id !== ordered_question.id end)
      |> List.last()

    if previous_question do
      swap_questions_in_set(q, previous_question, s)
      {:ok, "Moved up"}
    else
      {:error, "It's already the first question in the list"}
    end
  end

  def swap_questions_in_set(question1, question2, set) do
    j1 =
      Repo.get_by(Tzn.Questionnaire.QuestionSetQuestion,
        question_set_id: set.id,
        question_id: question1.id
      )

    j2 =
      Repo.get_by(Tzn.Questionnaire.QuestionSetQuestion,
        question_set_id: set.id,
        question_id: question2.id
      )

    Tzn.Questionnaire.QuestionSetQuestion.changeset(j1, %{display_order: j2.display_order})
    |> Repo.update()

    Tzn.Questionnaire.QuestionSetQuestion.changeset(j2, %{display_order: j1.display_order})
    |> Repo.update()

    {:ok, "Swapped display orders #{j1.display_order} and #{j2.display_order}"}
  end

  def list_questionnaires do
    Questionnaire
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload([:question_set, :mentee])
  end

  def get_questionnaire_by_access_key(key) do
    Questionnaire |> Repo.get_by!(access_key: key) |> Repo.preload([:mentee, :question_set])
  end

  def get_questionnaire_by_id(id) do
    Questionnaire |> Repo.get(id) |> Repo.preload([:mentee, :question_set])
  end

  def change_questionnaire(%Questionnaire{} = q, attrs \\ %{}) do
    Questionnaire.changeset(q, attrs)
  end

  def create_questionnaire(attrs) do
    %Questionnaire{}
    |> Questionnaire.changeset(attrs)
    |> Repo.insert()
  end

  def update_questionnare_state(%Questionnaire{} = q, new_state, _mentor) do
    change_questionnaire(q, %{state: new_state}) |> Repo.update()
  end

  @doc """
  Note these will not be in order!
  """
  def list_answers(%Questionnaire{} = q) do
    question_ids = Ecto.assoc(q, [:question_set, :questions]) |> Repo.all() |> Enum.map(& &1.id)

    from(a in Answer,
      where: a.mentee_id == ^q.mentee.id,
      where: a.question_id in ^question_ids
    )
    |> Repo.all()
  end

  defp create_or_update_answer(%Question{} = question, %Mentee{} = mentee, params) do
    case Repo.get_by(Answer, mentee_id: mentee.id, question_id: question.id) do
      nil -> %Answer{mentee: mentee, question: question}
      answer -> answer
    end
    |> Answer.changeset(params)
    |> Repo.insert_or_update()
  end

  def set_parent_answer(%Question{} = question, %Mentee{} = mentee, answer)
      when is_binary(answer) do
    create_or_update_answer(%Question{} = question, %Mentee{} = mentee, %{from_parent: answer})
  end

  def set_pod_answer(%Question{} = question, %Mentee{} = mentee, answer)
      when is_binary(answer) do
    create_or_update_answer(%Question{} = question, %Mentee{} = mentee, %{from_pod: answer})
  end
end
