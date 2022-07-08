defmodule Tzn.DB.Timeline do
  use Ecto.Schema
  import Ecto.Changeset

  schema "timelines" do
    field :access_key, :binary_id
    field :readonly_access_key, :binary_id
    field :graduation_year, :integer

    field :user_type, :string
    field :email, :string

    field :emailed_at, :naive_datetime

    many_to_many :calendars, Tzn.DB.Calendar, join_through: Tzn.DB.TimelineCalendar, on_replace: :delete
    timestamps()
  end

  def changeset(c, attrs) do
    c
    |> cast(attrs, [:access_key, :readonly_access_key, :graduation_year, :user_type, :email, :emailed_at])
    |> validate_required([:graduation_year])
  end
end
