defmodule TznWeb.MentorControllerTest do
  use TznWeb.ConnCase

  alias Tzn.Transizion

  @create_attrs %{name: "some name"}
  @update_attrs %{name: "some updated name"}
  @invalid_attrs %{name: nil}

  def fixture(:mentor) do
    {:ok, mentor} = Transizion.create_mentor(@create_attrs)
    mentor
  end

  describe "index" do
    test "lists all mentors", %{conn: conn} do
      conn = get(conn, Routes.mentor_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Mentors"
    end
  end

  describe "new mentor" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.mentor_path(conn, :new))
      assert html_response(conn, 200) =~ "New Mentor"
    end
  end

  describe "create mentor" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.mentor_path(conn, :create), mentor: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.mentor_path(conn, :show, id)

      conn = get(conn, Routes.mentor_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Mentor"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.mentor_path(conn, :create), mentor: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Mentor"
    end
  end

  describe "edit mentor" do
    setup [:create_mentor]

    test "renders form for editing chosen mentor", %{conn: conn, mentor: mentor} do
      conn = get(conn, Routes.mentor_path(conn, :edit, mentor))
      assert html_response(conn, 200) =~ "Edit Mentor"
    end
  end

  describe "update mentor" do
    setup [:create_mentor]

    test "redirects when data is valid", %{conn: conn, mentor: mentor} do
      conn = put(conn, Routes.mentor_path(conn, :update, mentor), mentor: @update_attrs)
      assert redirected_to(conn) == Routes.mentor_path(conn, :show, mentor)

      conn = get(conn, Routes.mentor_path(conn, :show, mentor))
      assert html_response(conn, 200) =~ "some updated name"
    end

    test "renders errors when data is invalid", %{conn: conn, mentor: mentor} do
      conn = put(conn, Routes.mentor_path(conn, :update, mentor), mentor: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Mentor"
    end
  end

  describe "delete mentor" do
    setup [:create_mentor]

    test "deletes chosen mentor", %{conn: conn, mentor: mentor} do
      conn = delete(conn, Routes.mentor_path(conn, :delete, mentor))
      assert redirected_to(conn) == Routes.mentor_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.mentor_path(conn, :show, mentor))
      end
    end
  end

  defp create_mentor(_) do
    mentor = fixture(:mentor)
    %{mentor: mentor}
  end
end
