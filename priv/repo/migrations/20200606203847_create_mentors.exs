defmodule Tzn.Repo.Migrations.CreateMentors do
  use Ecto.Migration

  def change do
    create table(:mentors) do
      add :name, :string

      timestamps()
    end

  end
end
