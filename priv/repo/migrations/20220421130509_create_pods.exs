defmodule Tzn.Repo.Migrations.CreatePods do
  use Ecto.Migration

  def change do
    create table(:pods) do
      add :mentee_id, references(:mentees, on_delete: :delete_all)
      add :mentor_id, references(:mentors, on_delete: :nilify_all)

      add :type, :string, null: false
      add :active, :boolean, default: true
      add :internal_note, :text
      add :mentor_rate, :decimal

      add :mentor_todo_notes, :text
      add :parent_todo_notes, :text
      add :mentee_todo_notes, :text

      add :college_list_access, :boolean, default: false
      add :ecvo_list_access, :boolean, default: false
      add :scholarship_list_access, :boolean, default: false

      timestamps()
    end

    create index("pods", [:mentee_id])
    create index("pods", [:mentor_id])
    create index("pods", [:active])
    create index("pods", [:type])

    alter table(:contract_purchases) do
      add :pod_id, references(:pods, on_delete: :nilify_all)
    end
    alter table(:strategy_sessions) do
      add :pod_id, references(:pods, on_delete: :nilify_all)
    end
    alter table(:timesheet_entries) do
      add :pod_id, references(:pods, on_delete: :nilify_all)
    end

    create index("contract_purchases", [:pod_id])
    create index("strategy_sessions", [:pod_id])
    create index("timesheet_entries", [:pod_id])
  end
end
