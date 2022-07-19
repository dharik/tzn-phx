defmodule Tzn.DB.Calendar do
  use Ecto.Schema
  import Ecto.Changeset

  schema "calendars" do
    field(:name, :string)
    field(:lookup_name, :string) # for auto update script
    field(:subscribed_by_default, :boolean, default: false)
    field(:searchable, :boolean)
    field(:searchable_name, :string)
    field(:type, :string)

    has_many :events, Tzn.DB.CalendarEvent

    timestamps()
  end

  def changeset(c, attrs) do
    c
    |> cast(attrs, [:name, :lookup_name, :searchable_name, :searchable, :type, :subscribed_by_default])
    |> validate_required([:name, :lookup_name, :searchable, :type, :subscribed_by_default])
    |> unique_constraint(:lookup_name)
  end
end
