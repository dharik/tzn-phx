defmodule Tzn.Timesheets do
  import Ecto.Query

  alias Tzn.Repo
  alias Tzn.Transizion.{TimesheetEntry, Mentee, Mentor, MentorHourCounts}

  @spec get_timesheet_entry!(number()) :: struct()
  def get_timesheet_entry!(id),
    do: Repo.get!(TimesheetEntry, id) |> Repo.preload([:mentor, pod: [:mentee]])

  def create_timesheet_entry(attrs \\ %{})

  # Hourly rate is overridden (for admin changes)
  def create_timesheet_entry(attrs = %{"hourly_rate" => _}) do
    %TimesheetEntry{}
    |> TimesheetEntry.changeset(attrs)
    |> Repo.insert()
  end

  def create_timesheet_entry(attrs = %{"mentor_id" => mentor_id, "pod_id" => pod_id}) do
    mentor = Tzn.Transizion.get_mentor!(mentor_id)

    pod = Tzn.Pods.get_pod(pod_id)

    rate =
      if pod && pod.mentor_rate do
        pod.mentor_rate
      else
        mentor.hourly_rate
      end

    %TimesheetEntry{}
    |> Map.put(:hourly_rate, rate)
    |> TimesheetEntry.changeset(attrs)
    |> Repo.insert()
  end

  def update_timesheet_entry(%TimesheetEntry{} = timesheet_entry, attrs) do
    timesheet_entry
    |> TimesheetEntry.changeset(attrs)
    |> Repo.update()
  end

  def delete_timesheet_entry(%TimesheetEntry{} = timesheet_entry) do
    Repo.delete(timesheet_entry)
  end

  # TODO
  # Should this check the category
  # and run side-validations based on category? Like if a pod_id needs to be set
  def change_timesheet_entry(%TimesheetEntry{} = timesheet_entry, attrs \\ %{}) do
    TimesheetEntry.changeset(timesheet_entry, attrs)
  end

  def hour_pay_stats(entries) do
    hours =
      entries
      |> Enum.map(fn entry ->
        Timex.diff(entry.ended_at, entry.started_at, :duration)
      end)
      |> Enum.reduce(Timex.Duration.zero(), fn diff, acc ->
        Timex.Duration.add(acc, diff)
      end)
      |> Timex.Duration.to_hours()

    pay =
      entries
      |> Enum.map(fn entry ->
        hours =
          Timex.diff(entry.ended_at, entry.started_at, :duration) |> Timex.Duration.to_hours()

        hours * Decimal.to_float(entry.hourly_rate)
      end)
      |> Enum.sum()

    %{
      pay: Decimal.from_float(pay) |> Decimal.round(2),
      hours: hours |> Float.round(2),
    }
  end

  @spec mentor_timesheet_aggregate(number()) :: list()
  def mentor_timesheet_aggregate(mentor_id) do
    Repo.all(from(h in MentorHourCounts, where: h.mentor_id == ^mentor_id))
  end

  def list_entries do
    Repo.all(TimesheetEntry)
  end

  def list_entries(%Mentor{} = mentor) do
    Repo.all(
      from(e in TimesheetEntry, where: e.mentor_id == ^mentor.id, order_by: [desc: :started_at])
    )
  end

  def list_entries(%Mentee{} = mentee) do
    Repo.all(
      from(e in TimesheetEntry, where: e.mentee_id == ^mentee.id, order_by: [desc: :started_at])
    )
  end

  def list_entries(%Tzn.DB.Pod{} = pod) do
    Repo.all(from(e in TimesheetEntry, where: e.pod_id == ^pod.id, order_by: [desc: :started_at]))
  end

  defmodule Category do
    @derive Jason.Encoder
    defstruct [
      :name,
      :pod_type,
      :slug,
      requires_pod: true,
      max_minutes: nil,
      max_minutes_message: ""
    ]
  end

  def categories(%Mentor{}, nil) do
    categories() |> Enum.filter(&(&1.requires_pod == false))
  end

  def categories(%Mentor{}, %Tzn.DB.Pod{type: type}) do
    categories() |> Enum.filter(&(&1.pod_type == type))
  end

  def categories do
    [
      %Category{name: "Research Specialist", slug: "research_specialist", requires_pod: false},
      %Category{
        name: "Research for Parent",
        slug: "research_for_parent",
        requires_pod: false,
        max_minutes: 15,
        max_minutes_message:
          "Research for parents should take 15 minutes or less. If you've used more, please log it under the specific mentee. Feel free to ask your CMT if you have questions!"
      },
      %Category{name: "Task from CMT or Jason", slug: "cmt_or_jason", requires_pod: false},
      %Category{
        name: "Responding to CMT or SST on Slack",
        slug: "cmt_or_sst_response",
        requires_pod: false
      },
      %Category{
        name: "Introduction Call",
        slug: "intro_call",
        requires_pod: false,
        max_minutes: 60,
        max_minutes_message:
          "Initial calls with parents and students should not take longer than an hour. If you've exceeded that time, please let your CMT know so they can help  you troubleshoot!"
      },
      #
      %Category{
        name: "Scholarship Applications",
        slug: "scholarship_applications",
        pod_type: "college_mentoring"
      },
      %Category{
        name: "Client Communication: emailing parents or Slacking students",
        slug: "client_communication",
        pod_type: "college_mentoring"
      },
      %Category{
        name: "Essay Revision during a Meeting",
        slug: "essay_revision",
        pod_type: "college_mentoring"
      },
      %Category{
        name: "Course Selection",
        slug: "course_selection",
        pod_type: "college_mentoring"
      },
      %Category{
        name: "Extracurricular Applications, including resume creation",
        # TODO: Fix naming
        slug: "extracurriculuar_applications",
        pod_type: "college_mentoring"
      },
      %Category{
        name: "Missed Session",
        slug: "missed_session",
        pod_type: "college_mentoring",
        max_minutes: 30,
        max_minutes_message:
          "Missed sessions are capped at 30 minutes. As always, you can Slack your CMT if you have questions!"
      },
      %Category{name: "Asynchronous Work", slug: "async_work", pod_type: "college_mentoring"},
      %Category{
        name: "College Applications",
        slug: "college_applications",
        pod_type: "college_mentoring"
      },
      %Category{name: "Interview Prep", slug: "interview_prep", pod_type: "college_mentoring"},
      #
      %Category{name: "Tutoring Meeting", slug: "tutoring_meeting", pod_type: "tutoring"},
      %Category{
        name: "Asynchronous: Finding Resources",
        slug: "async_finding_resources",
        pod_type: "tutoring"
      },
      %Category{
        name: "Asynchronous: Meeting Preparation",
        slug: "async_meeting_prep",
        pod_type: "tutoring"
      },
      %Category{
        name: "Client Communication: emailing parents or Slacking students",
        slug: "client_communication",
        pod_type: "tutoring"
      },
      %Category{
        name: "Missed Session",
        slug: "missed_session",
        pod_type: "tutoring",
        max_minutes: 30,
        max_minutes_message:
          "Missed sessions are capped at 30 minutes. As always, you can Slack your CMT if you have questions!"
      },
      #
      %Category{name: "Brainstorming", slug: "brainstorming", pod_type: "capstone"},
      %Category{name: "Developing the Project", slug: "project", pod_type: "capstone"},
      %Category{name: "Creating a Website", slug: "website", pod_type: "capstone"},
      %Category{
        name: "Working on a Submission to a Conference or Journal",
        slug: "conference_journal_submission",
        pod_type: "capstone"
      },
      %Category{name: "Wrap-Up", pod_type: "capstone", slug: "wrap_up"},
      %Category{
        name: "Client Communication: emailing parents or Slacking students",
        slug: "client_communication",
        pod_type: "capstone"
      },
      %Category{
        name: "Missed Session",
        slug: "missed_session",
        pod_type: "capstone",
        max_minutes: 30,
        max_minutes_message:
          "Missed sessions are capped at 30 minutes. As always, you can Slack your CMT if you have questions!"
      }
    ]
  end

  @spec get_category_by_slug(String.t()) :: Category
  def get_category_by_slug("uncategorized") do
    %Category{
      name: "Uncategorized",
      slug: "uncategorized",
      requires_pod: false
    }
  end

  def get_category_by_slug(slug) when is_binary(slug) do
    categories() |> Enum.find(&(&1.slug == slug))
  end
end
