defmodule Tzn.Jobs.SendStrategySessionEmails do
  import Ecto.Query

  alias Tzn.Transizion.StrategySession
  alias Tzn.Repo

  @auth ""
  @template_id = ""
  @sendgrid_url = "https://api.sendgrid.com/v3/mail/send"


  def run do
    headers = [
      Authorization: @auth,
      "Content-Type": "application/json"
    ]

    sessions =
      Repo.all(
        from s in StrategySession,
          where: s.emailed == false and s.published ==  true
      )
      |> Repo.preload([:mentee, :mentor])

    sessions
    |> Enum.map(fn s ->
      if s.mentee.parent1_email do
        send_email(
          s.mentee.parent1_email,
          s.mentee.parent1_name,
          s.mentee.name,
          s.mentor.name,
          s.notes,
          s.title,
          s.email_subject
          "dharik@transizion.com",
          s.mentor.name
        )
      end

      if s.mentee.parent2_email do
        end_email(
          s.mentee.parent2_email,
          s.mentee.parent2_name,
          s.mentee.name,
          s.mentor.name,
          s.notes,
          s.title,
          s.email_subject
          "dharik@transizion.com",
          s.mentor.name
        )
      end

      StrategySession.email_sent_changeset(s) |> Repo.update
    end)
  end

  def send_email(
    to_email,
    to_name,
    mentee_name,
    mentor_name,
    session_notes,
    session_title,
    subject,
    from_email,
    from_name,
  ) do
    body = %{
      personalizations: [
        %{
          to: [
            %{
              email: to_email
              name: to_name
            }
          ],
          dynamic_template_data: %{
            mentee_name: mentee_name,
            parent_name: to_name,
            mentor_name: mentor_name,
            session_notes: session_notes
          },
          subject: subject
        }
      ],
      from: %{
        email: from_email,
        name: from_name
      },
      subject: "Strategy session: #{session_title}",
      template_id: @template_id
    }

    {:ok, body_json} = Jason.encode(body)
    IO.inspect(HTTPoison.post(@sendgrid_url, body_json, headers))
  end
end
