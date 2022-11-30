defmodule Tzn.ResearchListEmailer do
  alias Tzn.Repo
  alias Tzn.Questionnaire.Questionnaire
  alias Tzn.Transizion.Mentor

  def send_parent_email(%Questionnaire{} = questionnaire, email_body, %Mentor{} = mentor)
      when is_binary(email_body) do
    mentee = questionnaire.mentee

    subject =
      cond do
        questionnaire.question_set_id == Tzn.Questionnaire.college_list_question_set().id ->
          "#{Tzn.Util.informal_name(mentee)}'s College List"

        questionnaire.question_set_id == Tzn.EcvoLists.ecvo_list_question_set().id ->
          "#{Tzn.Util.informal_name(mentee)}'s Extracurricular/Volunteer Opportunity List"

        questionnaire.question_set_id == Tzn.ScholarshipLists.scholarship_list_question_set().id ->
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
    Tzn.Questionnaire.change_questionnaire(questionnaire, %{parent_email_sent_at: Timex.now()})
    |> Repo.update()
  end
end
