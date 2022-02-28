defmodule Tzn.Timesheets do
  import Ecto.Query

  alias Tzn.Repo
  alias Tzn.Transizion.{TimesheetEntry, Mentee, Mentor, MentorHourCounts}
  alias Tzn.Users.User

  @spec get_timesheet_entry!(number()) :: struct()
  def get_timesheet_entry!(id), do: Repo.get!(TimesheetEntry, id)

  def create_timesheet_entry(attrs \\ %{})

  # Why is this overloaded?
  def create_timesheet_entry(attrs = %{"hourly_rate" => _}) do
    %TimesheetEntry{}
    |> TimesheetEntry.changeset(attrs)
    |> Repo.insert()
  end

  def create_timesheet_entry(attrs = %{"mentor_id" => mentor_id, "mentee_id" => mentee_id}) do
    mentor = Tzn.Transizion.get_mentor!(mentor_id)

    mentee =
      if !is_nil(mentee_id) && mentee_id != "" do
        Tzn.Transizion.get_mentee(mentee_id)
      else
        nil
      end

    rate =
      if mentee && mentee.mentor_rate do
        mentee.mentor_rate
      else
        mentor.hourly_rate
      end

    %TimesheetEntry{}
    |> Map.put(:hourly_rate, rate)
    |> TimesheetEntry.changeset(attrs)
    |> Repo.insert()
  end

  def update_timesheet_entry(%TimesheetEntry{} = timesheet_entry, attrs) do
    timesheet_entry
    |> TimesheetEntry.changeset(attrs)
    |> Repo.update()
  end

  def delete_timesheet_entry(%TimesheetEntry{} = timesheet_entry) do
    Repo.delete(timesheet_entry)
  end

  # TODO
  # Should this check the category
  # and run side-validations based on category? Like if a mentee_id needs to be set
  def change_timesheet_entry(%TimesheetEntry{} = timesheet_entry, attrs \\ %{}) do
    TimesheetEntry.changeset(timesheet_entry, attrs)
  end

  def hour_pay_stats(_entries) do
    %{total_hours: 3, estimated_pay: 55}
  end

  @spec mentor_timesheet_aggregate(number()) :: list()
  def mentor_timesheet_aggregate(mentor_id) do
    Repo.all(from(h in MentorHourCounts, where: h.mentor_id == ^mentor_id))
  end

  def list_entries do
    Repo.all(TimesheetEntry)
  end

  def list_entries(%Mentor{} = mentor) do
    Repo.all(
      from(e in TimesheetEntry, where: e.mentor_id == ^mentor.id, order_by: [desc: :started_at])
    )
  end

  def list_entries(%Mentee{} = mentee) do
    Repo.all(
      from(e in TimesheetEntry, where: e.mentee_id == ^mentee.id, order_by: [desc: :started_at])
    )
  end

  def list_entries(%User{}) do
    # TODO
  end

  def timesheet_categories(%User{}) do
  end

  def timesheet_categories(%Mentor{}) do
  end

  # Category = { name, description, requires_mentee, show_todo_list_update, requires_todo_list_update, etc }
end
