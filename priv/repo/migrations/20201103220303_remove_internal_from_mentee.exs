defmodule Tzn.Repo.Migrations.RemoveInternalFromMentee do
  use Ecto.Migration

  def change do
    alter table :mentees do
      remove :internal_name
    end
  end
end
