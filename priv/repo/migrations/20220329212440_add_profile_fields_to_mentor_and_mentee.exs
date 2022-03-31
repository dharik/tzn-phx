defmodule Tzn.Repo.Migrations.AddProfileFieldsToMentorAndMentee do
  use Ecto.Migration

  def change do
    alter table :mentees do
      add :nick_name, :string
      add :timezone_offset, :integer
      add :pronouns, :string

      add :archived_reason, :string
    end

    alter table :mentors do
      add :pronouns, :string
      add :timezone_offset, :integer
      add :nick_name, :string
      add :desired_mentee_count, :integer
      add :max_mentee_count, :integer

      add :archived_reason, :string
    end
  end
end
