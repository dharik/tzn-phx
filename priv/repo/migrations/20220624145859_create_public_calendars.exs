defmodule Tzn.Repo.Migrations.CreatePublicCalendars do
  use Ecto.Migration

  def change do
    create table(:calendars) do
      add :name, :string

      add :subscribed_by_default, :boolean

      add :searchable_name, :string
      add :searchable, :boolean

      add :type, :text

      timestamps()
    end

    create index(:calendars, [:searchable])
    create index(:calendars, [:type])

    create table(:calendar_events) do
      add :calendar_id, references(:calendars, on_delete: :nilify_all)

      add :name, :text
      add :description, :text

      add :month, :integer
      add :day, :integer
      add :grade, :string

      add :import_data, :map

      timestamps()
    end

    create index(:calendar_events, [:calendar_id])
    create index(:calendar_events, [:month, :day])
    create index(:calendar_events, [:grade])



    create table(:timelines) do
      add :access_key, :uuid, null: false
      add :readonly_access_key, :uuid, null: false

      add :graduation_year, :integer
      add :user_type, :string
      add :email, :string

      add :emailed_at, :naive_datetime

      timestamps()
    end

    create index(:timelines, [:email])
    create index(:timelines, [:graduation_year])
    create index(:timelines, [:access_key])
    create index(:timelines, [:readonly_access_key])


    create table(:timelines_calendars, primary_key: false) do
      add :calendar_id, references(:calendars, on_delete: :delete_all)
      add :timeline_id, references(:timelines, on_delete: :delete_all)
    end
    create index(:timelines_calendars, [:timeline_id])

  end
end
