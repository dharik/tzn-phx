defmodule Tzn.Repo.Migrations.AddHourlyRateToMentor do
  use Ecto.Migration

  def change do
    alter table :mentors do
      add :hourly_rate, :decimal, default: 40.0
    end
  end
end
