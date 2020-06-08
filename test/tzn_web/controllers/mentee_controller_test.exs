defmodule TznWeb.MenteeControllerTest do
  use TznWeb.ConnCase

  alias Tzn.Transizion

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:mentee) do
    {:ok, mentee} = Transizion.create_mentee(@create_attrs)
    mentee
  end

  describe "index" do
    test "lists all mentees", %{conn: conn} do
      conn = get(conn, Routes.mentee_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Mentees"
    end
  end

  describe "new mentee" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.mentee_path(conn, :new))
      assert html_response(conn, 200) =~ "New Mentee"
    end
  end

  describe "create mentee" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.mentee_path(conn, :create), mentee: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.mentee_path(conn, :show, id)

      conn = get(conn, Routes.mentee_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Mentee"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.mentee_path(conn, :create), mentee: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Mentee"
    end
  end

  describe "edit mentee" do
    setup [:create_mentee]

    test "renders form for editing chosen mentee", %{conn: conn, mentee: mentee} do
      conn = get(conn, Routes.mentee_path(conn, :edit, mentee))
      assert html_response(conn, 200) =~ "Edit Mentee"
    end
  end

  describe "update mentee" do
    setup [:create_mentee]

    test "redirects when data is valid", %{conn: conn, mentee: mentee} do
      conn = put(conn, Routes.mentee_path(conn, :update, mentee), mentee: @update_attrs)
      assert redirected_to(conn) == Routes.mentee_path(conn, :show, mentee)

      conn = get(conn, Routes.mentee_path(conn, :show, mentee))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, mentee: mentee} do
      conn = put(conn, Routes.mentee_path(conn, :update, mentee), mentee: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Mentee"
    end
  end

  describe "delete mentee" do
    setup [:create_mentee]

    test "deletes chosen mentee", %{conn: conn, mentee: mentee} do
      conn = delete(conn, Routes.mentee_path(conn, :delete, mentee))
      assert redirected_to(conn) == Routes.mentee_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.mentee_path(conn, :show, mentee))
      end
    end
  end

  defp create_mentee(_) do
    mentee = fixture(:mentee)
    %{mentee: mentee}
  end
end
