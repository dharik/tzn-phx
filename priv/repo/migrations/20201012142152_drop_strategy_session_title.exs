defmodule Tzn.Repo.Migrations.DropStrategySessionTitle do
  use Ecto.Migration

  def change do
    alter table :strategy_sessions do
      remove :title
    end
  end
end
