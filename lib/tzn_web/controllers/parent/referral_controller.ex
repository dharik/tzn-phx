defmodule TznWeb.Parent.ReferralController do
  use TznWeb, :controller
  import TznWeb.ParentPlugs

  plug :put_layout, "parent.html"
  plug :ensure_parent_profile_and_mentees

  def show(conn, _params) do
    render(conn, "show.html")
  end

  def create(conn, %{"referral" => %{"note" => note}}) do
    case send_email(note, conn.assigns.parent_profile) do
      {:ok, _} ->
        conn
        |> put_flash(
          :info,
          "Thank you! Jason will follow up with the information you've provided."
        )
        |> render("show.html")

      {:error, _} ->
        conn
        |> put_flash(:error, "An error occured. Please try again or email Jason directly")
        |> render("show.html")
    end
  end

  def send_email(note, parent) do
    Tzn.Emails.Referral.referral_to_jason(note, parent) |> Tzn.Mailer.deliver()
  end
end
