defmodule TznWeb.Admin.UserController do
  use TznWeb, :controller

  alias Tzn.Users

  def index(conn, _params) do
    users = Users.list_users()
    render(conn, "index.html", users: users)
  end
end
