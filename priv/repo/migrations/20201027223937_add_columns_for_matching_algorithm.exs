defmodule Tzn.Repo.Migrations.AddColumnsForMatchingAlgorithm do
  use Ecto.Migration

  def change do
    alter table :mentors do
      add :career_interests, {:array, :string}
      add :school_tiers, {:array, :string}
      add :gender, :string
      add :hobbies, {:array, :string}
      add :disability_experience, :boolean
      add :social_factor, :string
      add :international_experience, :boolean
    end
  end
end
