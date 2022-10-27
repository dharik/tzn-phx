defmodule Tzn.Repo.Migrations.AddUserIdIndexToMentors do
  use Ecto.Migration

  def change do
    create index(:mentors, [:user_id, :email])
    create index(:mentees, [:email, :parent1_email, :parent2_email, :archived])
  end
end
