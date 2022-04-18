defmodule Tzn.Scripts.RemoveRisingGrades do
  import Ecto.Query
  alias Tzn.Transizion.Mentee
  alias Tzn.Transizion.MentorTimelineEvent
  alias Tzn.Repo
  require Logger

  def run do
    # Update the mentees
    from(m in Mentee,
      where: m.grade in ["rising freshman", "rising sophomore", "rising junior", "rising senior"]
    )
    |> Repo.all()
    |> Enum.each(fn m ->
      new_grade =
        case m.grade do
          "rising freshman" -> "middle_school"
          "rising sophomore" -> "freshman"
          "rising junior" -> "sophomore"
          "rising senior" -> "junior"
        end

      Logger.debug("Will update #{m.id} (#{m.name}) from #{m.grade} to #{new_grade}")
      {:ok, updated_mentee} = Mentee.changeset(m, %{grade: new_grade}) |> Repo.update()
      Logger.info("Updated #{m.id} (#{m.name}}) from #{m.grade} to #{updated_mentee.grade}")
    end)

    # Fix the timelines
    from(e in MentorTimelineEvent,
      where: e.grade in ["rising_freshman", "rising sophomore", "rising junior", "rising senior"]
    )
    |> Repo.all()
    |> Enum.each(fn e ->
      new_grade =
        case e.grade do
          "rising_freshman" -> "middle_school"
          "rising sophomore" -> "freshman"
          "rising junior" -> "sophomore"
          "rising senior" -> "junior"
        end

      Logger.debug("Will update #{e.id} from #{e.grade} to #{new_grade}")

      {:ok, updated_event} =
        MentorTimelineEvent.changeset(e, %{grade: new_grade}) |> Repo.update()

      Logger.info("Updated #{e.id} from #{e.grade} to #{updated_event.grade}")

      #  No timesheet entries with "rising" status
    end)
  end
end
