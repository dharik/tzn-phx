defmodule Tzn.Repo.Migrations.AddInternalNoteToAnswers do
  use Ecto.Migration

  def change do
    alter table :answers do
      add :internal, :text
    end
  end
end
