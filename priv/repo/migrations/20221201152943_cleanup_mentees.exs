defmodule Tzn.Repo.Migrations.CleanupMentees do
  use Ecto.Migration

  def change do
    alter table(:mentees) do
      remove :mentor_id
      remove :mentor_rate
      remove :type
    end
  end
end
