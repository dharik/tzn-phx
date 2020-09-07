defmodule Tzn.Jobs.SendStrategySessionEmails do
  import Ecto.Query

  alias Tzn.Transizion.StrategySession
  alias Tzn.Repo

  @auth "FILL ME"

  def run do
    # From sendgrid
    template_id = "d-6b8a7733b8fb4a4a957fcb9a24f9f61a"
    url = "https://api.sendgrid.com/v3/mail/send"

    headers = [
      Authorization: @auth,
      "Content-Type": "application/json"
    ]

    sessions =
      Repo.all(
        from s in StrategySession,
          where: s.emailed == false and s.published == true
      )
      |> Repo.preload([:mentee, :mentor])

    sessions
    |> Enum.filter(fn s ->
      # TODO: Parent2 email case
      s.mentee.parent1_email
    end)
    |> Enum.map(fn s ->
      body = %{
        personalizations: [
          %{
            to: [
              %{
                email: s.mentee.parent1_email,
                name: s.mentee.parent1_name
              }
            ],
            dynamic_template_data: %{
              mentee_name: s.mentee.name,
              parent_name: s.mentee.parent1_name,
              mentor_name: s.mentor.name,
              session_notes: s.notes
            },
            subject: s.email_subject
          }
        ],
        from: %{
          email: "dharik@transizion.com",
          name: s.mentor.name
        },
        subject: "Strategy session: #{s.title}",
        template_id: template_id,
        mail_settings: %{
          sandbox_mode: %{
            enable: false
          }
        }
      }

      {:ok, body_json} = Jason.encode(body)
      IO.inspect(HTTPoison.post(url, body_json, headers))
    end)
  end
end
