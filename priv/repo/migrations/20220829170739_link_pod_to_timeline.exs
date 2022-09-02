defmodule Tzn.Repo.Migrations.LinkPodToTimeline do
  use Ecto.Migration

  def change do
    alter table(:pods) do
      add :timeline_id, references(:timelines, on_delete: :nilify_all)
    end
  end
end
