defmodule Tzn.Repo.Migrations.UseTextColumns do
  use Ecto.Migration

  def change do
    alter table :mentees do
      modify :internal_note, :text
    end
    alter table :strategy_sessions do
      modify :notes, :text
    end
    alter table :timesheet_entries do
      modify :notes, :text
    end
    alter table :contract_purchases do
      modify :notes, :text
    end
  end
end
