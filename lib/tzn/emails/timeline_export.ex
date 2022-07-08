defmodule Tzn.Emails.TimelineExport do
  import Swoosh.Email
  alias Tzn.DB.Timeline
  use Phoenix.Swoosh, view: TznWeb.EmailView, layout: {TznWeb.LayoutView, :email}

  def send_timeline(timeline = %Timeline{}) do
    new()
    |> from({"OrganiZeU by Transizion", "organizeu@transizion.com"})
    |> to(timeline.email)
    |> bcc("organizeu@transizion.com")
    |> subject("College Timeline from OrganiZeU (TODO)")
    |> render_body("timeline_export.html", %{
      access_key: ShortUUID.encode!(timeline.access_key),
      readonly_access_key: ShortUUID.encode!(timeline.readonly_access_key)
    })
    |> Tzn.Mailer.deliver!()

    Tzn.Emails.append_email_history(timeline.email, "timeline:#{timeline.id}")

    Tzn.Timelines.update_timeline(timeline, %{
      emailed_at: Timex.now() |> Timex.to_naive_datetime()
    })
  end
end
