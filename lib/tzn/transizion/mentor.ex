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

  def career_interest_options do
    [
      {"Business, finance, entrepreneurship", "business"},
      {"Computer science, coding", "computer_science"},
      {"Engineering", "engineering"},
      {"Journalism, writing, marketing", "journalism"},
      {"Chemistry, biology", "chemistry"},
      {"Physics", "physics"},
      {"Nursing", "nursing"},
      {"Pre-med (close to chem and bio)", "premed"},
      {"Sports nutrition", "sports_nutrition"},
      {"Economics", "economics"},
      {"Undeclared/liberal arts, humanities", "liberal_arts"},
      {"Math", "math"},
      {"Political science", "political_science"}
    ]
  end

  def hobby_options do
    [
      {"Travel", "travel"},
      {"Volunteering", "volunteering"},
      {"Hiking", "hiking"},
      {"Watching sports", "watching_sports"},
      {"Playing sports", "playing_sports"},
      {"Singing", "singing"},
      {"Playing instruments", "playing_instruments"},
      {"Gaming", "gaming"},
      {"Writing/blogging", "writing_blogging"},
      {"Learning and speaking languages", "languages"},
      {"Yoga", "yoga"},
      {"Lifting/exercise/running", "lift_exercise_run"},
      {"Movies/TV", "movies_tv"},
      {"Teaching/tutoring", "teaching_tutoring"},
      {"Photography", "photography"},
      {"Cooking/foodie", "cooking"},
      {"Poker/cards", "poker"},
      {"Reading", "reading"},
      {"Trivia", "trivia"},
      {"Painting", "painting"}
    ]
  end

  def school_tier_options do
    [
      {"Ivy League", "ivy"},
      {"Top 20-50", "top_20_50"},
      {"Top 50-100", "top_50_100"},
      {"Top 100+", "top_100_plus"}
    ]
  end
end
