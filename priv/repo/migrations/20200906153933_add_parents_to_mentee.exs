defmodule Tzn.Repo.Migrations.AddParentsToMentee do
  use Ecto.Migration

  def change do
    alter table :mentees do
      add :parent1_email, :string
      add :parent1_name, :string
      add :parent2_email, :string
      add :parent2_name, :string
    end
  end
end
