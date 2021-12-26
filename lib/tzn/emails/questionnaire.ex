defmodule Tzn.Emails.Questionnaire do
  import Swoosh.Email

  #Tzn.Emails.Questionnaire.welcome() |> Tzn.Mailer.deliver()
  def welcome(body) do
    new()
    |> to({"Dharik Patel Name", "dharik@transizion.com"})
    |> reply_to({"Mentor name", "dharik+asthementor@transizion.com"})
    |> from({"mentors", "mentors@transizion.com"})
    |> subject("Hello, Avengers!")
    |> html_body(body)
  end
end
