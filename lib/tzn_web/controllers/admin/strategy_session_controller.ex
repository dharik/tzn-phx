defmodule TznWeb.Admin.StrategySessionController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Repo

  def edit(conn, %{"id" => id}) do
    strategy_session = Transizion.get_strategy_session!(id) |> Repo.preload([:mentee, :mentor])
    changeset = Transizion.change_strategy_session(strategy_session)
    render(conn, "edit.html", strategy_session: strategy_session, changeset: changeset)
  end

  def update(conn, %{"id" => id, "strategy_session" => strategy_session_params}) do
    strategy_session = Transizion.get_strategy_session!(id)

    case Transizion.update_strategy_session(strategy_session, strategy_session_params) do
      {:ok, strategy_session} ->
        conn
        |> put_flash(:info, "Strategy Session updated successfully.")
        |> redirect(to: Routes.admin_strategy_session_path(conn, :edit, strategy_session))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "edit.html", strategy_session: strategy_session, changeset: changeset)
    end
  end

  def delete(conn, %{"id" => id}) do
    strategy_session = Transizion.get_strategy_session!(id) |> Repo.preload(:mentee)
    {:ok, strategy_session} = Transizion.delete_strategy_session(strategy_session)

    conn
    |> put_flash(:info, "Strategy Session deleted successfully.")
    |> redirect(to: Routes.admin_mentee_path(conn, :show, strategy_session.mentee))
  end

end