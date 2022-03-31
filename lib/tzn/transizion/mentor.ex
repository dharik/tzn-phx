defmodule Tzn.Transizion.Mentor do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentors" do
    field :name, :string
    field :nick_name, :string
    field :pronouns, :string
    field :email, :string
    field :photo_url, :string
    field :archived, :boolean
    field :archived_reason, :string
    field :timezone_offset, :integer

    field :college_list_specialty, :boolean
    field :ecvo_list_specialty, :boolean
    field :scholarship_list_specialty, :boolean
    field :desired_mentee_count, :integer
    field :max_mentee_count, :integer

    # Matching algorithm
    field :career_interests, {:array, :string}
    field :school_tiers, {:array, :string}
    field :gender, :string
    field :hobbies, {:array, :string}
    field :disability_experience, :boolean
    field :social_factor, :string
    field :international_experience, :boolean

    # Acts as a default hourly rate
    field :hourly_rate, :decimal
    field :experience_level, :string

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
      :nick_name,
      :pronouns,
      :timezone_offset,
      :user_id,
      :email,
      :photo_url,
      :career_interests,
      :school_tiers,
      :gender,
      :hobbies,
      :disability_experience,
      :social_factor,
      :international_experience,
      :hourly_rate,
      :archived,
      :archived_reason,
      :experience_level,
      :college_list_specialty,
      :ecvo_list_specialty,
      :scholarship_list_specialty,
      :desired_mentee_count,
      :max_mentee_count
    ])
    |> validate_inclusion(:experience_level, ["veteran", "rising", "rookie"])
    |> validate_required([:name, :nick_name, :email, :hourly_rate])
    |> validate_archived()
    |> validate_archived_reason()
    |> cast_assoc(:user)
  end

  def validate_archived(changeset) do
    validate_change(changeset, :archived, fn :archived, archived ->
      if archived &&
           Ecto.assoc(changeset.data, :mentees)
           |> Tzn.Repo.all()
           |> Enum.any?(&(&1.archived == false)) do
        [archived: "Can't archive this mentor because there are still active mentees"]
      else
        []
      end
    end)
  end

  def validate_archived_reason(changeset) do
    if get_field(changeset, :archived) == true do
      validate_required(changeset, :archived_reason)
    else
      put_change(changeset, :archived_reason, nil)
    end
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
