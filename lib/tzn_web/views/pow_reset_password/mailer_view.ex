defmodule TznWeb.PowResetPassword.MailerView do
  use TznWeb, :mailer_view

  def subject(:reset_password, _assigns), do: "Reset password link"
end
