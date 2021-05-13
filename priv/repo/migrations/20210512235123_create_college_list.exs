defmodule Tzn.Repo.Migrations.CreateCollegeList do
  use Ecto.Migration

  def change do
    create table(:college_lists) do
      add :mentee_id, references(:mentees, on_delete: :delete_all)
      add :state, :string, null: false
      add :access_key, :uuid, null: false 

      timestamps()
    end

    create table(:college_list_questions) do
      add :active, :boolean, default: true, null: false
      add :parent_answer_required, :boolean, default: false, null: false
      add :question, :text
      add :display_order, :integer

      timestamps()
    end

    create table(:college_list_answers) do
      add :from_parent, :text
      add :from_pod, :text
      add :college_list_question_id, references(:college_list_questions, on_delete: :delete_all)
      add :college_list_id, references(:college_lists, on_delete: :delete_all)
      
      timestamps()
    end

    create unique_index(:college_lists, [:access_key])
    create unique_index(:college_list_answers, [:college_list_question_id, :college_list_id])
  end
end
