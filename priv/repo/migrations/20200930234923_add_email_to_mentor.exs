defmodule Tzn.Repo.Migrations.AddEmailToMentor do
  use Ecto.Migration

  def change do
    alter table :mentors do
      add :email, :string
    end
  end
end
