defmodule Tzn.Repo.Migrations.AddFeatureAccessTogglesToMentees do
  use Ecto.Migration

  def change do
    alter table :mentees do
      add :college_list_access, :boolean
      add :ecvo_list_access, :boolean
      add :scholarship_list_access, :boolean
    end
  end
end
