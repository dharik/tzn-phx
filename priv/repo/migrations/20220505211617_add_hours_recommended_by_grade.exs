defmodule Tzn.Repo.Migrations.AddHoursRecommendedByGrade do
  use Ecto.Migration

  def change do
    alter table(:pods) do
      add :hours_recommended_freshman, :decimal
      add :hours_recommended_sophomore, :decimal
      add :hours_recommended_junior, :decimal
      add :hours_recommended_senior, :decimal
      add :hours_cap_freshman, :decimal
      add :hours_cap_sophomore, :decimal
      add :hours_cap_junior, :decimal
      add :hours_cap_senior, :decimal
    end
  end
end
