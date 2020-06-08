defmodule TznWeb.TimesheetEntryControllerTest do
  use TznWeb.ConnCase

  alias Tzn.Transizion

  @create_attrs %{date: ~N[2010-04-17 14:00:00], hours: 120.5, notes: "some notes"}
  @update_attrs %{date: ~N[2011-05-18 15:01:01], hours: 456.7, notes: "some updated notes"}
  @invalid_attrs %{date: nil, hours: nil, notes: nil}

  def fixture(:timesheet_entry) do
    {:ok, timesheet_entry} = Transizion.create_timesheet_entry(@create_attrs)
    timesheet_entry
  end

  describe "index" do
    test "lists all timesheet_entries", %{conn: conn} do
      conn = get(conn, Routes.timesheet_entry_path(conn, :index))
      assert html_response(conn, 200) =~ "Listing Timesheet entries"
    end
  end

  describe "new timesheet_entry" do
    test "renders form", %{conn: conn} do
      conn = get(conn, Routes.timesheet_entry_path(conn, :new))
      assert html_response(conn, 200) =~ "New Timesheet entry"
    end
  end

  describe "create timesheet_entry" do
    test "redirects to show when data is valid", %{conn: conn} do
      conn = post(conn, Routes.timesheet_entry_path(conn, :create), timesheet_entry: @create_attrs)

      assert %{id: id} = redirected_params(conn)
      assert redirected_to(conn) == Routes.timesheet_entry_path(conn, :show, id)

      conn = get(conn, Routes.timesheet_entry_path(conn, :show, id))
      assert html_response(conn, 200) =~ "Show Timesheet entry"
    end

    test "renders errors when data is invalid", %{conn: conn} do
      conn = post(conn, Routes.timesheet_entry_path(conn, :create), timesheet_entry: @invalid_attrs)
      assert html_response(conn, 200) =~ "New Timesheet entry"
    end
  end

  describe "edit timesheet_entry" do
    setup [:create_timesheet_entry]

    test "renders form for editing chosen timesheet_entry", %{conn: conn, timesheet_entry: timesheet_entry} do
      conn = get(conn, Routes.timesheet_entry_path(conn, :edit, timesheet_entry))
      assert html_response(conn, 200) =~ "Edit Timesheet entry"
    end
  end

  describe "update timesheet_entry" do
    setup [:create_timesheet_entry]

    test "redirects when data is valid", %{conn: conn, timesheet_entry: timesheet_entry} do
      conn = put(conn, Routes.timesheet_entry_path(conn, :update, timesheet_entry), timesheet_entry: @update_attrs)
      assert redirected_to(conn) == Routes.timesheet_entry_path(conn, :show, timesheet_entry)

      conn = get(conn, Routes.timesheet_entry_path(conn, :show, timesheet_entry))
      assert html_response(conn, 200) =~ "some updated notes"
    end

    test "renders errors when data is invalid", %{conn: conn, timesheet_entry: timesheet_entry} do
      conn = put(conn, Routes.timesheet_entry_path(conn, :update, timesheet_entry), timesheet_entry: @invalid_attrs)
      assert html_response(conn, 200) =~ "Edit Timesheet entry"
    end
  end

  describe "delete timesheet_entry" do
    setup [:create_timesheet_entry]

    test "deletes chosen timesheet_entry", %{conn: conn, timesheet_entry: timesheet_entry} do
      conn = delete(conn, Routes.timesheet_entry_path(conn, :delete, timesheet_entry))
      assert redirected_to(conn) == Routes.timesheet_entry_path(conn, :index)
      assert_error_sent 404, fn ->
        get(conn, Routes.timesheet_entry_path(conn, :show, timesheet_entry))
      end
    end
  end

  defp create_timesheet_entry(_) do
    timesheet_entry = fixture(:timesheet_entry)
    %{timesheet_entry: timesheet_entry}
  end
end
