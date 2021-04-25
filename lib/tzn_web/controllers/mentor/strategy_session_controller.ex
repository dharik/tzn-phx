defmodule TznWeb.Mentor.StrategySessionController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Transizion.StrategySession
  alias Tzn.Repo

  def new(conn, %{"mentee_id" => mentee_id} = params) do
    default_datetime = Timex.now() |> Timex.shift(hours: -6) |> Timex.to_naive_datetime()

    changeset =
      Transizion.change_strategy_session(
        %StrategySession{
          date: default_datetime
        },
        params
      )

    mentee =
      if mentee_id do
        Transizion.get_mentee!(mentee_id) |> Repo.preload(:hour_counts)
      else
        nil
      end

    render(conn, "new.html", changeset: changeset, mentee: mentee)
  end

  def create(conn, %{"strategy_session" => strategy_session_params = %{"mentee_id" => mentee_id}}) do
    mentee = Transizion.get_mentee!(mentee_id) |> Repo.preload(:hour_counts)

    case Transizion.create_strategy_session(
           strategy_session_params
           |> Map.put_new("mentor_id", conn.assigns.current_mentor.id)
           |> Map.put("published", true)
         ) do
      {:ok, strategy_session} ->
        conn
        |> redirect(to: Routes.mentor_strategy_session_path(conn, :edit, strategy_session))

      {:error, %Ecto.Changeset{} = changeset} ->
        render(conn, "new.html", changeset: changeset, mentee: mentee)
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
        "strategy_session" => strategy_session_params
      }) do
    strategy_session = Transizion.get_strategy_session!(id)

    case Transizion.update_strategy_session(
           strategy_session,
           strategy_session_params |> Map.put("published", true)
         ) do
      {:ok, _trategy_session} ->
        conn
        |> put_flash(:info, "Strategy session updated successfully.")
        |> redirect(to: Routes.mentor_mentee_path(conn, :show, strategy_session.mentee_id))

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
