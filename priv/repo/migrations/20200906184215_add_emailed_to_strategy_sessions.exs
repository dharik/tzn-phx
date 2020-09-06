defmodule Tzn.Repo.Migrations.AddEmailedToStrategySessions do
  use Ecto.Migration

  def change do
    alter table :strategy_sessions do
      add :emailed, :boolean, default: false
    end
  end
end
