defmodule Tzn.PodGroupReporting do
  alias Tzn.DB.{PodGroup, Pod}
  alias Tzn.Transizion.TimesheetEntry

  alias Tzn.Repo
  import Ecto.Query

  @spec hours_mentored([%PodGroup{} | integer()]) :: float()
  def hours_mentored(groups) do
    groups
    |> Tzn.Repo.batch_get(PodGroup)
    |> Ecto.assoc([:pods, :hour_counts])
    |> select([hc], sum(hc.hours_used))
    |> Repo.one()
    |> Number.Conversion.to_float()
    |> Float.round(2)
  end

  @spec num_students([%PodGroup{} | integer()]) :: non_neg_integer()
  def num_students(groups) do
    groups
    |> Tzn.Repo.batch_get(PodGroup)
    |> Ecto.assoc([:pods])
    |> select([p], count(1))
    |> Repo.one()
  end

  @spec missed_sessions([%PodGroup{} | integer()]) :: [%TimesheetEntry{}]
  def missed_sessions(groups) do
    groups
    |> Tzn.Repo.batch_get(PodGroup)
    |> Ecto.assoc([:pods, :timesheet_entries])
    |> where([tse], tse.category == "missed_session")
    |> select([tse], count(1))
    |> Repo.one()
  end

  def student_highlights(%PodGroup{}) do
    # missed meetings in the last month
    # hours mentored > 10
    # hours mentored > 5
    # signed up in the last month
    #
  end

  def student_highlights(%Pod{} = pod) do
    pod = pod |> Repo.preload([:hour_counts, :mentee, :timesheet_entries])

    missed_sessions_this_month =
      pod.timesheet_entries
      |> Enum.filter(fn tse ->
        tse.category == "missed_session" && Tzn.Util.within_n_days_ago(tse.started_at, 30)
      end)
      |> Enum.count()

    missed_meetings_in_a_row =
      pod.timesheet_entries
      |> Enum.sort_by(& &1.started_at, {:desc, NaiveDateTime})
      |> Enum.take_while(&(&1.category == "missed_session"))
      |> Enum.count()

    milestones_completed =
      pod.todos |> Enum.filter(&(&1.is_milestone && &1.completed)) |> Enum.count()

    milestones_total = pod.todos |> Enum.filter(& &1.is_milestone) |> Enum.count()

    recent_milestone_completed_at = pod.todos
      |> Enum.filter(&(&1.is_milestone && &1.completed))
      |> Enum.sort_by(&(&1.completed_changed_at), {:desc, NaiveDateTime})
      |> List.first(%{completed_changed_at: nil})
      |> Map.get(:completed_changed_at)

    recently_opened_flags =
      pod.flags
      |> Enum.filter(&(&1.status != "resolved"))
      |> Enum.filter(fn f -> Tzn.Util.within_n_days_ago(f.inserted_at, 30) end)
      |> Enum.count()

    hours_mentored_hit_5_at =
      pod.timesheet_entries
      |> Enum.sort_by(& &1.started_at, {:asc, NaiveDateTime})
      |> Enum.reduce_while({0.0, nil}, fn tse, {hours_mentored, _} = acc ->
        if hours_mentored > 5.0 do
          {:halt, acc}
        else
          {:cont,
           {hours_mentored +
              (Timex.diff(tse.ended_at, tse.started_at, :duration) |> Timex.Duration.to_hours()),
            tse.started_at}}
        end
      end)
      |> then(fn {hours, date} ->
        if hours > 5.0 do
          date
        else
          nil
        end
      end)

    hours_mentored_hit_10_at =
      pod.timesheet_entries
      |> Enum.sort_by(& &1.started_at, {:asc, NaiveDateTime})
      |> Enum.reduce_while({0.0, nil}, fn tse, {hours_mentored, _} = acc ->
        if hours_mentored > 5.0 do
          {:halt, acc}
        else
          {:cont,
           {hours_mentored +
              (Timex.diff(tse.ended_at, tse.started_at, :duration) |> Timex.Duration.to_hours()),
            tse.started_at}}
        end
      end)
      |> then(fn {hours, date} ->
        if hours > 10.0 do
          date
        else
          nil
        end
      end)

    signup_date = pod.mentee && pod.mentee.inserted_at

    %{
      missed_sessions_last_30_days: missed_sessions_this_month,
      consecutive_missed_sessions: missed_meetings_in_a_row,
      hours_mentored_hit_5_at: hours_mentored_hit_5_at,
      hours_mentored_hit_10_at: hours_mentored_hit_10_at,
      onboarded_at: signup_date,
      milestones_completed: milestones_completed,
      milestones_total: milestones_total,
      last_milestone_completion: recent_milestone_completed_at
    }
  end
end
