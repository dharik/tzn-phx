defmodule TznWeb.StrategySessionControllerTest do
  use TznWeb.ConnCase

  alias Tzn.Transizion

  @create_attrs %{date: ~N[2010-04-17 14:00:00], notes: "some notes", published: true, title: "some title"}
  @update_attrs %{date: ~N[2011-05-18 15:01:01], notes: "some updated notes", published: false, title: "some updated title"}
  @invalid_attrs %{date: nil, notes: nil, published: nil, title: nil}

  def fixture(:strategy_session) do
    {:ok, strategy_session} = Transizion.create_strategy_session(@create_attrs)
    strategy_session
  end

  describe "index" do
    test "lists all strategy_sessions", %{conn: conn} do
      conn = get(conn, Routes.strategy_session_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Strategy sessions"
    end
  end

  describe "new strategy_session" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.strategy_session_path(conn, :new))
      assert html_response(conn, 200) =~ "New Strategy session"
    end
  end

  describe "create strategy_session" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.strategy_session_path(conn, :create), strategy_session: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.strategy_session_path(conn, :show, id)

      conn = get(conn, Routes.strategy_session_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Strategy session"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.strategy_session_path(conn, :create), strategy_session: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Strategy session"
    end
  end

  describe "edit strategy_session" do
    setup [:create_strategy_session]

    test "renders form for editing chosen strategy_session", %{conn: conn, strategy_session: strategy_session} do
      conn = get(conn, Routes.strategy_session_path(conn, :edit, strategy_session))
      assert html_response(conn, 200) =~ "Edit Strategy session"
    end
  end

  describe "update strategy_session" do
    setup [:create_strategy_session]

    test "redirects when data is valid", %{conn: conn, strategy_session: strategy_session} do
      conn = put(conn, Routes.strategy_session_path(conn, :update, strategy_session), strategy_session: @update_attrs)
      assert redirected_to(conn) == Routes.strategy_session_path(conn, :show, strategy_session)

      conn = get(conn, Routes.strategy_session_path(conn, :show, strategy_session))
      assert html_response(conn, 200) =~ "some updated notes"
    end

    test "renders errors when data is invalid", %{conn: conn, strategy_session: strategy_session} do
      conn = put(conn, Routes.strategy_session_path(conn, :update, strategy_session), strategy_session: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Strategy session"
    end
  end

  describe "delete strategy_session" do
    setup [:create_strategy_session]

    test "deletes chosen strategy_session", %{conn: conn, strategy_session: strategy_session} do
      conn = delete(conn, Routes.strategy_session_path(conn, :delete, strategy_session))
      assert redirected_to(conn) == Routes.strategy_session_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.strategy_session_path(conn, :show, strategy_session))
      end
    end
  end

  defp create_strategy_session(_) do
    strategy_session = fixture(:strategy_session)
    %{strategy_session: strategy_session}
  end
end
