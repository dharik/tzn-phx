defmodule TznWeb.Admin.MatchingAlgorithmController do
  use TznWeb, :controller

  def show(conn, _params) do
    render(conn, "show.html")
  end 

end