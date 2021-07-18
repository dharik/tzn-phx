defmodule Tzn.Repo.Migrations.AddDesignationToMentorProfiles do
  use Ecto.Migration

  def change do
    alter table :mentors do
      add :experience_level, :string
    end
  end
end
