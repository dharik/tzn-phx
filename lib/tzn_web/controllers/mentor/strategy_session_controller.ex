defmodule TznWeb.Mentor.StrategySessionController do
  use TznWeb, :controller

  import TznWeb.MentorPlugs
  plug :load_my_mentees
  plug :load_mentor_profile

  alias Tzn.Transizion
  alias Tzn.Transizion.StrategySession
  alias Tzn.Repo
  import IEx

  def index(conn, _params) do
    strategy_sessions = Transizion.list_strategy_sessions()
    render(conn, "index.html", strategy_sessions: strategy_sessions)
  end

  def new(conn, _params) do
    changeset = Transizion.change_strategy_session(%StrategySession{})
    render(conn, "new.html", changeset: changeset)
  end

  def create(conn, %{"strategy_session" => strategy_session_params}) do
    case Transizion.create_strategy_session(
           strategy_session_params
           |> Map.put_new("mentor_id", conn.assigns.current_user.id)
         ) do
      {:ok, strategy_session} ->
        conn
        |> redirect(to: Routes.mentor_strategy_session_path(conn, :edit, strategy_session))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset)
    end
  end

  def show(conn, %{"id" => id}) do
    strategy_session = Transizion.get_strategy_session!(id)
    render(conn, "show.html", strategy_session: strategy_session)
  end

  def edit(conn, %{"id" => id}) do
    strategy_session = Transizion.get_strategy_session!(id) |> Repo.preload(:mentee)
    changeset = Transizion.change_strategy_session(strategy_session)
    render(conn, "edit.html", strategy_session: strategy_session, changeset: changeset)
  end

  def update(conn, %{
        "id" => id,
        "strategy_session" => strategy_session_params,
        "submit_btn" => submit_btn
      }) do
    strategy_session = Transizion.get_strategy_session!(id)

    published =
      if submit_btn == "publish" do
        true
      else
        false
      end

    case Transizion.update_strategy_session(
           strategy_session,
           strategy_session_params |> Map.put("published", published)
         ) do
      {:ok, strategy_session} ->
        conn
        |> put_flash(:info, "Strategy session updated successfully.")
        |> redirect(to: Routes.mentor_strategy_session_path(conn, :edit, strategy_session))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", strategy_session: strategy_session, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    strategy_session = Transizion.get_strategy_session!(id)
    {:ok, _strategy_session} = Transizion.delete_strategy_session(strategy_session)

    conn
    |> put_flash(:info, "Strategy session deleted successfully.")
    |> redirect(to: Routes.mentor_strategy_session_path(conn, :index))
  end
end
