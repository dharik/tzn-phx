defmodule Tzn.Transizion do
  @moduledoc """
  The Transizion context.
  """

  import Ecto.Query, warn: false
  alias Tzn.Repo

  alias Tzn.Transizion.Mentor

  def list_mentors do
    Repo.all(Mentor)
  end

  def get_mentor!(id), do: Repo.get!(Mentor, id)

  @doc """
  Creates a mentor.

  ## Examples

      iex> create_mentor(%{field: value})
      {:ok, %Mentor{}}

      iex> create_mentor(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mentor(attrs \\ %{}) do
    %Mentor{}
    |> Mentor.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mentor.

  ## Examples

      iex> update_mentor(mentor, %{field: new_value})
      {:ok, %Mentor{}}

      iex> update_mentor(mentor, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mentor(%Mentor{} = mentor, attrs) do
    mentor
    |> Mentor.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mentor.

  ## Examples

      iex> delete_mentor(mentor)
      {:ok, %Mentor{}}

      iex> delete_mentor(mentor)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mentor(%Mentor{} = mentor) do
    Repo.delete(mentor)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mentor changes.

  ## Examples

      iex> change_mentor(mentor)
      %Ecto.Changeset{data: %Mentor{}}

  """
  def change_mentor(%Mentor{} = mentor, attrs \\ %{}) do
    Mentor.changeset(mentor, attrs)
  end

  alias Tzn.Transizion.Mentee
  alias Tzn.Transizion.MenteeWithHours

  def list_mentees do
    Repo.all(MenteeWithHours)
  end

  @doc """
  Gets a single mentee.

  Raises `Ecto.NoResultsError` if the Mentee does not exist.

  """
  def get_mentee!(id), do: Repo.get!(Mentee, id)

  @doc """
  Creates a mentee.

  ## Examples

      iex> create_mentee(%{field: value})
      {:ok, %Mentee{}}

      iex> create_mentee(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_mentee(attrs \\ %{}) do
    %Mentee{}
    |> Mentee.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a mentee.

  ## Examples

      iex> update_mentee(mentee, %{field: new_value})
      {:ok, %Mentee{}}

      iex> update_mentee(mentee, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_mentee(%Mentee{} = mentee, attrs) do
    mentee
    |> Mentee.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a mentee.

  ## Examples

      iex> delete_mentee(mentee)
      {:ok, %Mentee{}}

      iex> delete_mentee(mentee)
      {:error, %Ecto.Changeset{}}

  """
  def delete_mentee(%Mentee{} = mentee) do
    Repo.delete(mentee)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking mentee changes.

  ## Examples

      iex> change_mentee(mentee)
      %Ecto.Changeset{data: %Mentee{}}

  """
  def change_mentee(%Mentee{} = mentee, attrs \\ %{}) do
    Mentee.changeset(mentee, attrs)
  end

  alias Tzn.Transizion.StrategySession

  @doc """
  Returns the list of strategy_sessions.

  ## Examples

      iex> list_strategy_sessions()
      [%StrategySession{}, ...]

  """
  def list_strategy_sessions do
    Repo.all(StrategySession)
  end

  @doc """
  Gets a single strategy_session.

  Raises `Ecto.NoResultsError` if the Strategy session does not exist.

  ## Examples

      iex> get_strategy_session!(123)
      %StrategySession{}

      iex> get_strategy_session!(456)
      ** (Ecto.NoResultsError)

  """
  def get_strategy_session!(id), do: Repo.get!(StrategySession, id)

  @doc """
  Creates a strategy_session.

  ## Examples

      iex> create_strategy_session(%{field: value})
      {:ok, %StrategySession{}}

      iex> create_strategy_session(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_strategy_session(attrs \\ %{}) do
    %StrategySession{}
    |> StrategySession.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a strategy_session.

  ## Examples

      iex> update_strategy_session(strategy_session, %{field: new_value})
      {:ok, %StrategySession{}}

      iex> update_strategy_session(strategy_session, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_strategy_session(%StrategySession{} = strategy_session, attrs) do
    strategy_session
    |> StrategySession.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a strategy_session.

  ## Examples

      iex> delete_strategy_session(strategy_session)
      {:ok, %StrategySession{}}

      iex> delete_strategy_session(strategy_session)
      {:error, %Ecto.Changeset{}}

  """
  def delete_strategy_session(%StrategySession{} = strategy_session) do
    Repo.delete(strategy_session)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking strategy_session changes.

  ## Examples

      iex> change_strategy_session(strategy_session)
      %Ecto.Changeset{data: %StrategySession{}}

  """
  def change_strategy_session(%StrategySession{} = strategy_session, attrs \\ %{}) do
    StrategySession.changeset(strategy_session, attrs)
  end

  alias Tzn.Transizion.TimesheetEntry

  @doc """
  Returns the list of timesheet_entries.

  ## Examples

      iex> list_timesheet_entries()
      [%TimesheetEntry{}, ...]

  """
  def list_timesheet_entries do
    Repo.all(TimesheetEntry)
  end

  @doc """
  Gets a single timesheet_entry.

  Raises `Ecto.NoResultsError` if the Timesheet entry does not exist.

  ## Examples

      iex> get_timesheet_entry!(123)
      %TimesheetEntry{}

      iex> get_timesheet_entry!(456)
      ** (Ecto.NoResultsError)

  """
  def get_timesheet_entry!(id), do: Repo.get!(TimesheetEntry, id)

  @doc """
  Creates a timesheet_entry.

  ## Examples

      iex> create_timesheet_entry(%{field: value})
      {:ok, %TimesheetEntry{}}

      iex> create_timesheet_entry(%{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def create_timesheet_entry(attrs \\ %{}) do
    %TimesheetEntry{}
    |> TimesheetEntry.changeset(attrs)
    |> Repo.insert()
  end

  @doc """
  Updates a timesheet_entry.

  ## Examples

      iex> update_timesheet_entry(timesheet_entry, %{field: new_value})
      {:ok, %TimesheetEntry{}}

      iex> update_timesheet_entry(timesheet_entry, %{field: bad_value})
      {:error, %Ecto.Changeset{}}

  """
  def update_timesheet_entry(%TimesheetEntry{} = timesheet_entry, attrs) do
    timesheet_entry
    |> TimesheetEntry.changeset(attrs)
    |> Repo.update()
  end

  @doc """
  Deletes a timesheet_entry.

  ## Examples

      iex> delete_timesheet_entry(timesheet_entry)
      {:ok, %TimesheetEntry{}}

      iex> delete_timesheet_entry(timesheet_entry)
      {:error, %Ecto.Changeset{}}

  """
  def delete_timesheet_entry(%TimesheetEntry{} = timesheet_entry) do
    Repo.delete(timesheet_entry)
  end

  @doc """
  Returns an `%Ecto.Changeset{}` for tracking timesheet_entry changes.

  ## Examples

      iex> change_timesheet_entry(timesheet_entry)
      %Ecto.Changeset{data: %TimesheetEntry{}}

  """
  def change_timesheet_entry(%TimesheetEntry{} = timesheet_entry, attrs \\ %{}) do
    TimesheetEntry.changeset(timesheet_entry, attrs)
  end
end
