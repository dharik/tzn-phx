defmodule Tzn.Repo.Migrations.AddArchiveToProfiles do
  use Ecto.Migration

  def change do
    alter table :mentees do
      add :archived, :boolean, default: false
    end
    alter table :mentors do
      add :archived, :boolean, default: false
    end
  end
end
