defmodule Tzn.Transizion.TimesheetEntry do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timesheet_entries" do
    field :started_at, :naive_datetime
    field :ended_at, :naive_datetime
    field :notes, :string
    field :hourly_rate, :decimal
    field :category, :string
    belongs_to :mentor, Tzn.Transizion.Mentor
    belongs_to :mentee, Tzn.Transizion.Mentee

    timestamps()
  end

  @doc false
  def changeset(timesheet_entry, attrs) do
    timesheet_entry
    |> cast(attrs, [
      :started_at,
      :ended_at,
      :notes,
      :mentor_id,
      :mentee_id,
      :hourly_rate,
      :category
    ])
    |> validate_required([:started_at, :ended_at, :mentor_id, :category])
    |> notes_maybe_required()
    |> ended_after_started()
    |> duration_is_reasonable()
    |> duration_within_category_limit()
    # TODO: Check that mentor can make an entry for mentee_id
    # TODO: Check that if category requires_mentee that mentee_id is set
  end

  def notes_maybe_required(changeset) do
    validate_change(changeset, :category, fn :category, category_slug ->
      category = Tzn.Timesheets.get_category_by_slug(category_slug)
      notes = get_field(changeset, :notes)

      if category.requires_mentee == false && (!notes || String.length(notes) < 2) do
        [notes: "required"]
      else
        []
      end
    end)
  end

  def ended_after_started(changeset) do
    validate_change(changeset, :ended_at, fn :ended_at, _value ->
      started_at = get_field(changeset, :started_at)
      ended_at = get_field(changeset, :ended_at)

      if NaiveDateTime.compare(ended_at, started_at) != :gt do
        [ended_at: "must end after start time"]
      else
        []
      end
    end)
  end

  def duration_is_reasonable(changeset) do
    validate_change(changeset, :ended_at, fn :ended_at, _value ->
      started_at = get_field(changeset, :started_at)
      ended_at = get_field(changeset, :ended_at)

      if NaiveDateTime.diff(ended_at, started_at, :second) > 3600 * 3 do
        [ended_at: "shouldn't be greater than 3 hours"]
      else
        []
      end
    end)
  end

  def duration_within_category_limit(changeset = %{valid?: true}) do
    with category_slug <- get_field(changeset, :category),
         started_at <- get_field(changeset, :started_at),
         ended_at <- get_field(changeset, :ended_at),
         category <- Tzn.Timesheets.get_category_by_slug(category_slug),
         true <- is_number(category.max_minutes),
         true <- NaiveDateTime.diff(ended_at, started_at, :second) > category.max_minutes * 60 do
      add_error(changeset, :ended_at, category.max_minutes_message)
    else
      _ -> changeset
    end
  end

  def duration_within_category_limit(changeset) do
    changeset
  end
end
