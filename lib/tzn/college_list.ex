defmodule Tzn.CollegeList do
  import Ecto.Query, warn: false

  alias Tzn.Repo
  alias Tzn.Transizion.Mentee

  alias Tzn.CollegeList.CollegeList
  alias Tzn.CollegeList.Answer
  alias Tzn.CollegeList.Question

  def list_active_questions do
    Repo.all(from(q in Question, where: q.active == true, order_by: q.display_order))
  end

  def get_college_list_by_id(id) do
    Repo.get(CollegeList, id)
  end

  def get_college_list_by_access_key(access_key) do
    Repo.get_by(CollegeList, access_key: access_key)
  end

  def get_college_list_by_mentee(mentee = %Mentee{}) do
    Repo.get_by(CollegeList, mentee: mentee.id)
  end

  def serialize_college_list(college_list = %CollegeList{}) do
    questions = list_active_questions()

    answers_query = from(a in Answer, where: a.college_list_id == ^college_list.id)
    answers = Repo.all(answers_query)

    serialized_questions_and_answers =
      Enum.map(questions, fn q ->
        answer =
          Enum.find(answers, %{parent_response: nil, pod_response: nil}, fn a ->
            a.college_list_question_id == q.id
          end)

        %{
          question: %{id: q.id},
          parent_answer: answer.parent_response,
          pod_answer: answer.pod_response
        }
      end)

    %{
      questionairre: serialized_questions_and_answers
    }

    # %{
    #   questionairre: [%{question: %{id, question, display_order...}, parent_answer:, pod_answer: }],
    #   state: 'waiting_on_parent'
    # }
  end

  # def update_college_list(%Mentee{} = mentee, updates = %{}) do
  #   updates = %{
  #     state?: '',
  #     questionaire?: [%{question_slug: '', answer: ''}]
  #   }
  # end

  #
  # Admin
  #
  def list_questions do
    Question |> order_by(asc: :display_order) |> Repo.all()
  end

  def list_college_lists do
    CollegeList |> Repo.all()
  end

  # new_or_updated_questions: array of changes per question
  # [
  #   %{question: "this will be updated", active: true, parent_answer_required: true, id: 1},
  #   %{question: "this will be inserted", active: false, parent_answer_required: true}
  # ]
  # NOTE: You should pass in ALL questions in an ordered array
  # This still works with a subset of questions but it'll mess up your display_orders
  def set_college_list_questions(new_or_updated_questions) do
    existing_questions = list_questions()

    changesets =
      new_or_updated_questions
      # |> Enum.sort() # TODO: Move inactive questions last  to keep display_order clean
      |> Enum.with_index()
      |> Enum.map(fn {changes, index} -> changes |> Map.put(:display_order, index) end)
      |> Enum.map(fn changes ->
        Question.changeset(
          Enum.find(existing_questions, %Question{}, fn q -> q.id == Map.get(changes, :id, -1) end),
          changes
        )
      end)

    all_valid =
      changesets
      |> Enum.all?(fn c ->
        c.valid?
      end)

    if all_valid do
      changesets |> Enum.map(&Repo.insert_or_update!/1)
      {:ok, "All updated"}
    else
      {:error, changesets |> Enum.reject(fn c -> c.valid? end)}
    end
  end
end
