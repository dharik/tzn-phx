defmodule Tzn.Repo.Migrations.AddGradeToMentee do
  use Ecto.Migration

  def change do
    alter table :mentees do
      add :grade, :string
    end
  end
end
