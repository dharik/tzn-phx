defmodule TznWeb.Mentor.CollegeListController do
  use TznWeb, :controller

  # See all pending college lists
  # This is just for specialist mentors
  def index(conn, _) do

  end

  # Open a specific college list
  def show(conn, _) do
    render(conn, "show.html")
  end

  # Modify a college list
  def update(conn, _) do

  end
end
