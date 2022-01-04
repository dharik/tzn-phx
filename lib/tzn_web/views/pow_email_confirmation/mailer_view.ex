defmodule TznWeb.PowEmailConfirmation.MailerView do
  use TznWeb, :mailer_view

  def subject(:email_confirmation, _assigns), do: "Confirm your email address"
end
