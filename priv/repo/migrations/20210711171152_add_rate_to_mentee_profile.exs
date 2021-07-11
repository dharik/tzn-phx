defmodule Tzn.Repo.Migrations.AddRateToMenteeProfile do
  use Ecto.Migration

  def up do
    alter table :mentees do
      add :mentor_rate, :decimal
    end
  end
end
