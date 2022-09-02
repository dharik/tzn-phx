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

    many_to_many :calendars, Tzn.DB.Calendar,
      join_through: Tzn.DB.TimelineCalendar,
      on_replace: :delete

    field :last_ical_sync_at, :naive_datetime
    field :last_ical_sync_client, :string

    has_one :pod, Tzn.DB.Pod

    timestamps()
  end

  def changeset(c, attrs) do
    c
    |> cast(attrs, [
      :access_key,
      :readonly_access_key,
      :graduation_year,
      :user_type,
      :email,
      :emailed_at,
      :updated_at,
      :last_ical_sync_at,
      :last_ical_sync_client
    ])
    |> validate_required([:graduation_year])
    |> maybe_validate_email_and_user_type()
  end

  def maybe_validate_email_and_user_type(c) do
    email = get_field(c, :email)
    user_type = get_field(c, :user_type)

    if email || user_type do
      c |> validate_required([:email, :user_type])
    else
      c
    end
  end
end
