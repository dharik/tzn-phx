defmodule Tzn.Repo.Migrations.AddPhotoToMentor do
  use Ecto.Migration

  def change do
    alter table :mentors do
      add :photo_url, :text
    end
  end
end
