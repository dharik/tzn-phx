defmodule Tzn.DB.CalendarEvent do
  use Ecto.Schema
  import Ecto.Changeset

  schema "calendar_events" do
    belongs_to(:calendar, Tzn.DB.Calendar)

    field(:name, :string)
    field(:description, :string)

    field(:month, :integer)
    field(:day, :integer)
    field(:grade, :string)

    field(:import_data, :map, load_in_query: false)

    timestamps()
  end

  def changeset(c, attrs) do
    c
    |> cast(attrs, [:name, :description, :month, :day, :grade, :calendar_id, :import_data])
    |> foreign_key_constraint(:calendar_id)
    |> validate_required([:name, :description, :month, :day, :grade])
    |> validate_inclusion(:grade, Tzn.Util.grade_options(:high_school) |> Keyword.values())
  end
end
