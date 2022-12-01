defmodule Tzn.Repo.Migrations.CleanupMenteeIdReferences do
  use Ecto.Migration

  def change do
    alter table(:timesheet_entries) do
      remove :mentee_id
    end
    alter table(:contract_purchases) do
      remove :mentee_id
    end
    alter table(:strategy_sessions) do
      remove :mentee_id
    end
  end
end
