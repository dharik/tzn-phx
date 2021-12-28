defmodule Tzn.Repo.Migrations.AddEmailReminderToQeustionnaire do
  use Ecto.Migration

  def change do
    alter table :questionnaires do
      add :access_key_used_at, :naive_datetime
      add :parent_email_sent_at, :naive_datetime
    end
  end
end
