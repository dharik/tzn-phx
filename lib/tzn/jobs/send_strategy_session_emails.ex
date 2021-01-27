defmodule Tzn.Jobs.SendStrategySessionEmails do
  import Ecto.Query

  alias Tzn.Transizion.StrategySession
  alias Tzn.Repo

  @template_id "d-6b8a7733b8fb4a4a957fcb9a24f9f61a"
  @sendgrid_url "https://api.sendgrid.com/v3/mail/send"

  import Logger

  def run do
    Logger.info("Running strategy session emails job")

    sessions =
      Repo.all(
        from s in StrategySession,
          where: s.emailed == false and s.published == true
      )
      |> Repo.preload([:mentor, mentee: [:hour_counts]])

    sessions
    |> Enum.map(fn s ->
      hours_left =
        s.mentee.hour_counts.hours_purchased
        |> Decimal.sub(s.mentee.hour_counts.hours_used)
        |> Decimal.round(1)
        |> Decimal.to_float()

      if s.mentee.parent1_email do
        send_email(
          s.mentee.parent1_email,
          s.mentee.parent1_name,
          s.mentee.name,
          s.mentor.name,
          s.notes,
          s.email_subject,
          s.mentor.email,
          s.mentor.name,
          s.mentee.email,
          hours_left
        )
      end

      if s.mentee.parent2_email do
        send_email(
          s.mentee.parent2_email,
          s.mentee.parent2_name,
          s.mentee.name,
          s.mentor.name,
          s.notes,
          s.email_subject,
          s.mentor.email,
          s.mentor.name,
          s.mentee.email,
          hours_left
        )
      end

      StrategySession.email_sent_changeset(s) |> Repo.update()
    end)
  end

  def send_email(
        to_email,
        to_name,
        mentee_name,
        mentor_name,
        session_notes,
        subject,
        reply_to_email,
        from_name,
        mentee_email,
        hours_left
      ) do
    headers = [
      Application.get_env(:tzn, :sendgrid_auth),
      "Content-Type": "application/json"
    ]

    Logger.info("Sending strategy session email to #{to_email}")

    cc =
      if mentee_email do
        [
          %{
            email: reply_to_email,
            name: from_name
          },
          %{
            email: mentee_email,
            name: mentee_name
          }
        ]
      else
        [
          %{
            email: reply_to_email,
            name: from_name
          }
        ]
      end

    body = %{
      personalizations: [
        %{
          to: [
            %{
              email: to_email,
              name: to_name
            }
          ],
          cc: cc,
          dynamic_template_data: %{
            mentee_name: mentee_name,
            parent_name: to_name,
            mentor_name: mentor_name,
            session_notes: session_notes,
            hours_left: hours_left
          },
          subject: subject
        }
      ],
      from: %{
        email: "mentors@transizion.com",
        name: from_name
      },
      reply_to: %{
        name: mentor_name,
        email: reply_to_email
      },
      subject: "Strategy Session Notes",
      template_id: @template_id
    }

    {:ok, body_json} = Jason.encode(body)
    IO.inspect(HTTPoison.post(@sendgrid_url, body_json, headers))
  end
end
