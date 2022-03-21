defmodule TznWeb.Parent.AdditionalOfferingsController do
  use TznWeb, :controller
  import TznWeb.ParentPlugs

  plug :ensure_parent_profile_and_mentees
  plug :load_mentee
  plug :put_layout, "parent.html"
  alias Tzn.Transizion

  def show(conn, _params) do
    conn
    |> render("show.html")
  end
end
