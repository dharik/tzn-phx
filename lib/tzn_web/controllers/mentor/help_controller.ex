defmodule TznWeb.Mentor.HelpController do
  use TznWeb, :controller

  def show(conn, _) do
    render(conn, "show.html")
  end
end
