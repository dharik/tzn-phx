defmodule Tzn.Repo.Migrations.AddEmailToMentee do
  use Ecto.Migration

  def change do
    alter table :mentees do
      add :email, :string
    end
  end
end
