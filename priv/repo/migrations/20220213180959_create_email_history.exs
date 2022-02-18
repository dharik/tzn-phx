defmodule Tzn.Repo.Migrations.CreateEmailHistory do
  use Ecto.Migration

  def change do
    create table(:email_history) do
      add :email_address, :string
      add :key, :string
      add :sent_at, :naive_datetime
    end

    create index(:email_history, [:email_address, :key, :sent_at])
  end
end
