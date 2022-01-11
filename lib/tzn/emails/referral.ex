defmodule Tzn.Emails.Referral do
  import Swoosh.Email

  def referral_to_jason(body, %Tzn.Transizion.Parent{} = p) do
    new()
    |> from({"Transizion", "support@transizion.com"})
    |> to("jason@transizion.com")
    |> subject("Referral")
    |> text_body(
        "Note:\n #{body}\n\n" <>
        "Parent Name:\n #{p.name}\n\n" <>
        "Parent Email:\n #{p.email}\n\n"
    )
  end
end
