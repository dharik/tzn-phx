defmodule Tzn.Repo.Migrations.AddColumnsForMatchingAlgorithm do
  use Ecto.Migration

  def change do
    alter table :mentors do
      add :career_interests, :string
      add :school_tiers, :string
      add :gender, :string
      add :experience_level, :string
      add :hobbies, :string
      add :disability_experience, :boolean
      add :social_factor, :string
      add :international_experience, :boolean
    end
  end
end
