defmodule Tzn.Repo.Migrations.AddListAccessCount do
  use Ecto.Migration

  def change do
    alter table(:pods) do
      add :college_list_limit, :integer
      add :ecvo_list_limit, :integer
      add :scholarship_list_limit, :integer
    end
  end
end
