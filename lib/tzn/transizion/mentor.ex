defmodule Tzn.Transizion.Mentor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentors" do
    field :name, :string
    field :email, :string

    # Matching algorithm
    field :career_interests, {:array, :string}
    field :school_tiers, {:array, :string}
    field :gender, :string
    field :hobbies, {:array, :string}
    field :disability_experience, :boolean
    field :social_factor, :string
    field :international_experience, :boolean

    has_many :mentees, Tzn.Transizion.Mentee
    has_many :timesheet_entries, Tzn.Transizion.TimesheetEntry
    has_many :strategy_sessions, Tzn.Transizion.StrategySession
    belongs_to :user, Tzn.Users.User
    has_many :monthly_hour_counts, Tzn.Transizion.MentorHourCounts
    timestamps()
  end

  @doc false
  def changeset(mentor, attrs) do
    mentor
    |> cast(attrs, [
      :name,
      :user_id,
      :email,
      :career_interests,
      :school_tiers,
      :gender,
      :hobbies,
      :disability_experience,
      :social_factor,
      :international_experience
    ])
    |> validate_required([:name, :email])
    |> cast_assoc(:user)
  end
end
