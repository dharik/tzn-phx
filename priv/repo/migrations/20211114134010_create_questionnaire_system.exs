defmodule Tzn.Repo.Migrations.CreateQuestionnaireSystem do
  use Ecto.Migration

  def change do
    create table(:questions) do
      add :question, :text
      add :placeholder, :text

      add :parent_answer_required, :boolean, default: false, null: false

      timestamps()
    end

    create table(:answers) do
      add :question_id, references(:questions, on_delete: :delete_all)
      add :mentee_id, references(:mentees, on_delete: :delete_all)

      add :from_parent, :text
      add :from_pod, :text

      timestamps()
    end
    create unique_index(:answers, [:mentee_id, :question_id]) # A question can only be answered once
    create index(:answers, [:mentee_id])

    create table(:question_sets) do
      add :name, :text
      add :slug, :text
    end

    create table(:question_sets_questions) do
      add :question_set_id, references(:question_sets, on_delete: :delete_all)
      add :question_id, references(:questions, on_delete: :delete_all)
      add :display_order, :integer
    end
    create unique_index(:question_sets_questions, [:question_set_id, :question_id])
    create index(:question_sets_questions, [:question_set_id])

    create table(:questionnaires) do
      add :mentee_id, references(:mentees, on_delete: :delete_all)
      add :question_set_id, references(:question_sets, on_delete: :delete_all)

      add :state, :string, null: false
      add :access_key, :uuid, null: false
      timestamps()
    end
    create unique_index(:questionnaires, [:access_key])
    create index(:questionnaires, [:mentee_id])
    create index(:questionnaires, [:state])

    alter table(:mentors) do
      add :college_list_specialty, :boolean, default: false, null: false
    end
  end
end
