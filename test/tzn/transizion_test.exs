defmodule Tzn.TransizionTest do
  use Tzn.DataCase

  alias Tzn.Transizion

  describe "mentors" do
    alias Tzn.Transizion.Mentor

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def mentor_fixture(attrs \\ %{}) do
      {:ok, mentor} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Transizion.create_mentor()

      mentor
    end

    test "list_mentors/0 returns all mentors" do
      mentor = mentor_fixture()
      assert Transizion.list_mentors() == [mentor]
    end

    test "get_mentor!/1 returns the mentor with given id" do
      mentor = mentor_fixture()
      assert Transizion.get_mentor!(mentor.id) == mentor
    end

    test "create_mentor/1 with valid data creates a mentor" do
      assert {:ok, %Mentor{} = mentor} = Transizion.create_mentor(@valid_attrs)
      assert mentor.name == "some name"
    end

    test "create_mentor/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transizion.create_mentor(@invalid_attrs)
    end

    test "update_mentor/2 with valid data updates the mentor" do
      mentor = mentor_fixture()
      assert {:ok, %Mentor{} = mentor} = Transizion.update_mentor(mentor, @update_attrs)
      assert mentor.name == "some updated name"
    end

    test "update_mentor/2 with invalid data returns error changeset" do
      mentor = mentor_fixture()
      assert {:error, %Ecto.Changeset{}} = Transizion.update_mentor(mentor, @invalid_attrs)
      assert mentor == Transizion.get_mentor!(mentor.id)
    end

    test "delete_mentor/1 deletes the mentor" do
      mentor = mentor_fixture()
      assert {:ok, %Mentor{}} = Transizion.delete_mentor(mentor)
      assert_raise Ecto.NoResultsError, fn -> Transizion.get_mentor!(mentor.id) end
    end

    test "change_mentor/1 returns a mentor changeset" do
      mentor = mentor_fixture()
      assert %Ecto.Changeset{} = Transizion.change_mentor(mentor)
    end
  end

  describe "mentees" do
    alias Tzn.Transizion.Mentee

    @valid_attrs %{name: "some name"}
    @update_attrs %{name: "some updated name"}
    @invalid_attrs %{name: nil}

    def mentee_fixture(attrs \\ %{}) do
      {:ok, mentee} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Transizion.create_mentee()

      mentee
    end

    test "list_mentees/0 returns all mentees" do
      mentee = mentee_fixture()
      assert Transizion.list_mentees() == [mentee]
    end

    test "get_mentee!/1 returns the mentee with given id" do
      mentee = mentee_fixture()
      assert Transizion.get_mentee!(mentee.id) == mentee
    end

    test "create_mentee/1 with valid data creates a mentee" do
      assert {:ok, %Mentee{} = mentee} = Transizion.create_mentee(@valid_attrs)
      assert mentee.name == "some name"
    end

    test "create_mentee/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transizion.create_mentee(@invalid_attrs)
    end

    test "update_mentee/2 with valid data updates the mentee" do
      mentee = mentee_fixture()
      assert {:ok, %Mentee{} = mentee} = Transizion.update_mentee(mentee, @update_attrs)
      assert mentee.name == "some updated name"
    end

    test "update_mentee/2 with invalid data returns error changeset" do
      mentee = mentee_fixture()
      assert {:error, %Ecto.Changeset{}} = Transizion.update_mentee(mentee, @invalid_attrs)
      assert mentee == Transizion.get_mentee!(mentee.id)
    end

    test "delete_mentee/1 deletes the mentee" do
      mentee = mentee_fixture()
      assert {:ok, %Mentee{}} = Transizion.delete_mentee(mentee)
      assert_raise Ecto.NoResultsError, fn -> Transizion.get_mentee!(mentee.id) end
    end

    test "change_mentee/1 returns a mentee changeset" do
      mentee = mentee_fixture()
      assert %Ecto.Changeset{} = Transizion.change_mentee(mentee)
    end
  end

  describe "strategy_sessions" do
    alias Tzn.Transizion.StrategySession

    @valid_attrs %{date: ~N[2010-04-17 14:00:00], notes: "some notes", published: true, title: "some title"}
    @update_attrs %{date: ~N[2011-05-18 15:01:01], notes: "some updated notes", published: false, title: "some updated title"}
    @invalid_attrs %{date: nil, notes: nil, published: nil, title: nil}

    def strategy_session_fixture(attrs \\ %{}) do
      {:ok, strategy_session} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Transizion.create_strategy_session()

      strategy_session
    end

    test "list_strategy_sessions/0 returns all strategy_sessions" do
      strategy_session = strategy_session_fixture()
      assert Transizion.list_strategy_sessions() == [strategy_session]
    end

    test "get_strategy_session!/1 returns the strategy_session with given id" do
      strategy_session = strategy_session_fixture()
      assert Transizion.get_strategy_session!(strategy_session.id) == strategy_session
    end

    test "create_strategy_session/1 with valid data creates a strategy_session" do
      assert {:ok, %StrategySession{} = strategy_session} = Transizion.create_strategy_session(@valid_attrs)
      assert strategy_session.date == ~N[2010-04-17 14:00:00]
      assert strategy_session.notes == "some notes"
      assert strategy_session.published == true
      assert strategy_session.title == "some title"
    end

    test "create_strategy_session/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transizion.create_strategy_session(@invalid_attrs)
    end

    test "update_strategy_session/2 with valid data updates the strategy_session" do
      strategy_session = strategy_session_fixture()
      assert {:ok, %StrategySession{} = strategy_session} = Transizion.update_strategy_session(strategy_session, @update_attrs)
      assert strategy_session.date == ~N[2011-05-18 15:01:01]
      assert strategy_session.notes == "some updated notes"
      assert strategy_session.published == false
      assert strategy_session.title == "some updated title"
    end

    test "update_strategy_session/2 with invalid data returns error changeset" do
      strategy_session = strategy_session_fixture()
      assert {:error, %Ecto.Changeset{}} = Transizion.update_strategy_session(strategy_session, @invalid_attrs)
      assert strategy_session == Transizion.get_strategy_session!(strategy_session.id)
    end

    test "delete_strategy_session/1 deletes the strategy_session" do
      strategy_session = strategy_session_fixture()
      assert {:ok, %StrategySession{}} = Transizion.delete_strategy_session(strategy_session)
      assert_raise Ecto.NoResultsError, fn -> Transizion.get_strategy_session!(strategy_session.id) end
    end

    test "change_strategy_session/1 returns a strategy_session changeset" do
      strategy_session = strategy_session_fixture()
      assert %Ecto.Changeset{} = Transizion.change_strategy_session(strategy_session)
    end
  end

  describe "timesheet_entries" do
    alias Tzn.Transizion.TimesheetEntry

    @valid_attrs %{date: ~N[2010-04-17 14:00:00], hours: 120.5, notes: "some notes"}
    @update_attrs %{date: ~N[2011-05-18 15:01:01], hours: 456.7, notes: "some updated notes"}
    @invalid_attrs %{date: nil, hours: nil, notes: nil}

    def timesheet_entry_fixture(attrs \\ %{}) do
      {:ok, timesheet_entry} =
        attrs
        |> Enum.into(@valid_attrs)
        |> Transizion.create_timesheet_entry()

      timesheet_entry
    end

    test "list_timesheet_entries/0 returns all timesheet_entries" do
      timesheet_entry = timesheet_entry_fixture()
      assert Transizion.list_timesheet_entries() == [timesheet_entry]
    end

    test "get_timesheet_entry!/1 returns the timesheet_entry with given id" do
      timesheet_entry = timesheet_entry_fixture()
      assert Transizion.get_timesheet_entry!(timesheet_entry.id) == timesheet_entry
    end

    test "create_timesheet_entry/1 with valid data creates a timesheet_entry" do
      assert {:ok, %TimesheetEntry{} = timesheet_entry} = Transizion.create_timesheet_entry(@valid_attrs)
      assert timesheet_entry.date == ~N[2010-04-17 14:00:00]
      assert timesheet_entry.hours == 120.5
      assert timesheet_entry.notes == "some notes"
    end

    test "create_timesheet_entry/1 with invalid data returns error changeset" do
      assert {:error, %Ecto.Changeset{}} = Transizion.create_timesheet_entry(@invalid_attrs)
    end

    test "update_timesheet_entry/2 with valid data updates the timesheet_entry" do
      timesheet_entry = timesheet_entry_fixture()
      assert {:ok, %TimesheetEntry{} = timesheet_entry} = Transizion.update_timesheet_entry(timesheet_entry, @update_attrs)
      assert timesheet_entry.date == ~N[2011-05-18 15:01:01]
      assert timesheet_entry.hours == 456.7
      assert timesheet_entry.notes == "some updated notes"
    end

    test "update_timesheet_entry/2 with invalid data returns error changeset" do
      timesheet_entry = timesheet_entry_fixture()
      assert {:error, %Ecto.Changeset{}} = Transizion.update_timesheet_entry(timesheet_entry, @invalid_attrs)
      assert timesheet_entry == Transizion.get_timesheet_entry!(timesheet_entry.id)
    end

    test "delete_timesheet_entry/1 deletes the timesheet_entry" do
      timesheet_entry = timesheet_entry_fixture()
      assert {:ok, %TimesheetEntry{}} = Transizion.delete_timesheet_entry(timesheet_entry)
      assert_raise Ecto.NoResultsError, fn -> Transizion.get_timesheet_entry!(timesheet_entry.id) end
    end

    test "change_timesheet_entry/1 returns a timesheet_entry changeset" do
      timesheet_entry = timesheet_entry_fixture()
      assert %Ecto.Changeset{} = Transizion.change_timesheet_entry(timesheet_entry)
    end
  end
end
