defmodule Tzn.Questionnaire do
  alias Tzn.Repo
  alias Tzn.Questionnaire.Question
  alias Tzn.Questionnaire.QuestionSet
  alias Tzn.Questionnaire.QuestionSetQuestion
  alias Tzn.Questionnaire.Questionnaire
  alias Tzn.Questionnaire.Answer
  alias Tzn.Transizion.Mentee
  alias Tzn.Transizion.Mentor

  alias Tzn.Users.User
  import Tzn.Policy

  import Ecto.Query

  def change_question(%Question{} = question, attrs \\ %{}) do
    Question.changeset(question, attrs)
  end

  def create_question(attrs \\ %{}, %User{} = current_user) do
    assert_admin(current_user)

    question_sets = list_question_sets(attrs["question_sets"])
    Enum.each(question_sets, &rewrite_display_orders/1)

    %Question{}
    |> Question.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:question_sets, question_sets)
    |> Repo.insert()
    |> case do
      {:ok, question} ->
        # Ensure question gets added to end of list
        Enum.each(question_sets, fn set ->
          new_display_order = max_display_order(set) + 1

          Repo.get_by!(QuestionSetQuestion, question_set_id: set.id, question_id: question.id)
          |> QuestionSetQuestion.changeset(%{display_order: new_display_order})
          |> Repo.update()
        end)

        {:ok, question}

      result ->
        result
    end
  end

  def update_question(%Question{} = question, attrs, %User{} = current_user) do
    assert_admin(current_user)

    previous_question_sets = question.question_sets
    new_question_sets = list_question_sets(attrs["question_sets"])
    Enum.each(new_question_sets, &rewrite_display_orders/1)

    question
    |> Question.changeset(attrs)
    |> Ecto.Changeset.put_assoc(:question_sets, new_question_sets)
    |> Repo.update()
    |> case do
      {:ok, question} ->
        # Ensure question is at bottom of new lists
        Enum.each(new_question_sets -- previous_question_sets, fn set ->
          new_display_order = max_display_order(set) + 1

          Repo.get_by!(QuestionSetQuestion, question_set_id: set.id, question_id: question.id)
          |> QuestionSetQuestion.changeset(%{display_order: new_display_order})
          |> Repo.update()
        end)

        {:ok, question}

      result ->
        result
    end
  end

  defp max_display_order(%QuestionSet{} = qs) do
    from(qsq in QuestionSetQuestion,
      where: qsq.question_set_id == ^qs.id,
      select: max(qsq.display_order)
    )
    |> Repo.one()
  end

  def list_questions(%User{} = current_user) do
    assert_admin(current_user)

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

  def ecvo_list_question_set do
    get_question_set_by_slug("ec_vo_list")
  end

  def scholarship_list_question_set do
    get_question_set_by_slug("scholarship_list")
  end

  @doc """
  Lists question in set in order, using display_order on the join table
  """
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

  defp rewrite_display_orders(%QuestionSet{} = qs) do
    Repo.all(
      from(qsq in QuestionSetQuestion,
        where: qsq.question_set_id == ^qs.id,
        order_by: [asc: qsq.display_order]
      )
    )
    |> Enum.with_index()
    |> Enum.each(fn {j, index} ->
      Repo.update(QuestionSetQuestion.changeset(j, %{display_order: index + 1}))
    end)
  end

  def move_question_down(%Question{} = q, %QuestionSet{} = s, %User{} = current_user) do
    assert_admin(current_user)

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

  def move_question_up(%Question{} = q, %QuestionSet{} = s, %User{} = current_user) do
    assert_admin(current_user)

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

  defp swap_questions_in_set(question1, question2, set) do
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

  def list_questionnaires(%User{} = current_user) do
    assert_admin_or_college_list_specialist(current_user)

    Questionnaire
    |> order_by(desc: :inserted_at)
    |> Repo.all()
    |> Repo.preload([:question_set, mentee: [pods: :mentor]])
  end

  def list_questionnaires(%Mentee{} = mentee) do
    mentee |> Ecto.assoc(:questionnaires) |> Repo.all()
  end

  @doc """
  This will modify the questionnaire
  """
  def get_questionnaire_by_access_key(key, current_user) do
    q = Questionnaire |> Repo.get_by!(access_key: key)

    if current_user == nil do
      change_questionnaire(q, %{access_key_used_at: Timex.now()}) |> Repo.update()
    end

    Repo.preload(q, [
      :mentee,
      :question_set,
      files: from(f in Tzn.Files.MenteeFile, where: is_nil(f.deleted_at))
    ])
  end

  def get_questionnaire_by_id(id, %User{} = current_user) do
    assert_admin_or_mentor(current_user)

    Questionnaire
    |> Repo.get(id)
    |> Repo.preload([
      :mentee,
      :question_set,
      files: from(f in Tzn.Files.MenteeFile, where: is_nil(f.deleted_at))
    ])
  end

  # TODO: Only if admin, mentee in current_mentor.mentees OR current_mentor.college_list_specialty
  def change_questionnaire(%Questionnaire{} = q, attrs \\ %{}) do
    Questionnaire.changeset(q, attrs)
  end

  # TODO: Only if admin | mentor
  # TODO: No duplicates, at least for now
  def create_questionnaire(attrs, %User{} = current_user) do
    assert_admin_or_mentor(current_user)

    %Questionnaire{}
    |> Questionnaire.changeset(attrs)
    |> Repo.insert()
  end

  def update_questionnare_state(%Questionnaire{} = q, new_state, %User{} = current_user) do
    assert_admin_or_mentor(current_user)
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

  def set_pod_answer(%Question{} = question, %Mentee{} = mentee, answer, %User{} = current_user)
      when is_binary(answer) do
    assert_admin_or_mentor(current_user)
    create_or_update_answer(%Question{} = question, %Mentee{} = mentee, %{from_pod: answer})
  end

  def set_internal_note(%Question{} = question, %Mentee{} = mentee, note, %User{} = current_user)
      when is_binary(note) do
    assert_admin_or_mentor(current_user)
    create_or_update_answer(%Question{} = question, %Mentee{} = mentee, %{internal: note})
  end

  def send_parent_email(%Questionnaire{} = questionnaire, email_body, %Mentor{} = mentor)
      when is_binary(email_body) do
    mentee = questionnaire.mentee

    subject =
      cond do
        questionnaire.question_set_id == college_list_question_set().id ->
          "#{Tzn.Util.informal_name(mentee)}'s College List"

        questionnaire.question_set_id == ecvo_list_question_set().id ->
          "#{Tzn.Util.informal_name(mentee)}'s Extracurricular/Volunteer Opportunity List"

        questionnaire.question_set_id == scholarship_list_question_set().id ->
          "#{Tzn.Util.informal_name(mentee)}'s Scholarship List"
      end

    if mentee.parent1_email do
      Tzn.Emails.Questionnaire.welcome(
        subject,
        email_body,
        Tzn.Util.informal_name(mentee),
        mentee.parent1_email,
        Tzn.Util.informal_name(mentor),
        mentor.email
      )
      |> Tzn.Mailer.deliver!()
    end

    if mentee.parent2_email do
      Tzn.Emails.Questionnaire.welcome(
        subject,
        email_body,
        Tzn.Util.informal_name(mentee),
        mentee.parent2_email,
        Tzn.Util.informal_name(mentor),
        mentor.email
      )
      |> Tzn.Mailer.deliver!()
    end

    # Mark as email sent
    change_questionnaire(questionnaire, %{parent_email_sent_at: Timex.now()}) |> Repo.update()
  end

  def attach_file(%Questionnaire{} = q, %Plug.Upload{} = file, %User{} = current_user) do
    # If there's a current_user, it should be an admin, mentor, or specialist mentor
    assert_admin_or_mentor(current_user)

    object_path = Ecto.UUID.generate() <> "/" <> file.filename

    Tzn.Files.upload!(
      object_path,
      File.read!(file.path),
      [questionnaire_id: q.id],
      file.content_type
    )

    Tzn.Files.MenteeFile.upload_changeset(%Tzn.Files.MenteeFile{}, %{
      object_path: object_path,
      file_name: file.filename,
      file_size: File.stat!(file.path).size,
      file_content_type: file.content_type,
      uploaded_by: current_user.id,
      questionnaire_id: q.id,
      mentee_id: q.mentee_id
    })
    |> Repo.insert()
  end

  @doc """
  This doesn't take a current user because parents can use the form anonymously
  and upload. So it'll be important to somehow keep these clean
  """
  def attach_file(%Questionnaire{} = q, %Plug.Upload{} = file, nil) do
    object_path = Ecto.UUID.generate() <> "/" <> file.filename

    Tzn.Files.upload!(
      object_path,
      File.read!(file.path),
      [questionnaire_id: q.id],
      file.content_type
    )

    Tzn.Files.MenteeFile.upload_changeset(%Tzn.Files.MenteeFile{}, %{
      object_path: object_path,
      file_name: file.filename,
      file_size: File.stat!(file.path).size,
      file_content_type: file.content_type,
      questionnaire_id: q.id,
      mentee_id: q.mentee_id
    })
    |> Repo.insert()
  end

  def only_college_lists(questionnaires) do
    Enum.filter(questionnaires, &(&1.question_set.slug == "college_list"))
  end
  def only_ecvo_lists(questionnaires) do
    Enum.filter(questionnaires, &(&1.question_set.slug == "ec_vo_list"))
  end
  def only_scholarship_lists(questionnaires) do
    Enum.filter(questionnaires, &(&1.question_set.slug == "scholarship_list"))
  end
end
