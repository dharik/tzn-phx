defmodule TznWeb.PageController do
  use TznWeb, :controller

  def index(conn, _params) do
    render(conn, "index.html")
  end
end
