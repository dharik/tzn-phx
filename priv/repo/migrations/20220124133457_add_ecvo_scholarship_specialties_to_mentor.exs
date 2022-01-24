defmodule Tzn.Repo.Migrations.AddECVOScholarshipSpecialtiesToMentor do
  use Ecto.Migration

  def change do
    alter table(:mentors) do
      add :ecvo_list_specialty, :boolean, default: false, null: false
      add :scholarship_list_specialty, :boolean, default: false, null: false
    end
  end
end
