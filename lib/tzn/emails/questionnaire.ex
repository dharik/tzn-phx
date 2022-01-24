defmodule Tzn.Emails.Questionnaire do
  import Swoosh.Email

  def welcome(subject, body, mentee_name, parent_email, mentor_name, mentor_email) do
    new()
    |> from({"Transizion", "mentors@transizion.com"})
    |> to(parent_email)
    |> cc({mentor_name, mentor_email})
    |> reply_to({mentor_name, mentor_email})
    |> bcc("mentors@transizion.com")
    |> subject(subject)
    |> html_body(body)
  end
end
