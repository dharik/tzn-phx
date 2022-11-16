defmodule Tzn.Repo.Migrations.DropListAccessOnMentee do
  use Ecto.Migration

  def change do
    alter table(:mentees) do
      remove :college_list_access
      remove :ecvo_list_access
      remove :scholarship_list_access
    end
  end
end
