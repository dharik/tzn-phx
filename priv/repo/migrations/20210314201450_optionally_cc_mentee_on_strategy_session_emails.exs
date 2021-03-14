defmodule Tzn.Repo.Migrations.OptionallyCCMenteeOnStrategySessionEmails do
  use Ecto.Migration

  def change do
    alter table :strategy_sessions do
      add :cc_mentee, :boolean, default: false
    end
  end
end
