defmodule TznWeb.Admin.MentorView do
  use TznWeb, :view
  alias Tzn.Transizion.TimesheetEntry

  def render("index.json", %{mentors: mentors, conn: conn}) do
    mentors
    |> Enum.map(fn mentor ->
      active_pods = mentor.pods |> Enum.filter(& &1.active)

      %{
        name: mentor.name,
        archived: mentor.archived,
        experience_level: mentor.experience_level,
        capacity:
          cond do
            mentor.max_mentee_count && mentor.desired_mentee_count ->
              min(mentor.max_mentee_count, mentor.desired_mentee_count) -
                Enum.count(active_pods)

            mentor.max_mentee_count ->
              mentor.max_mentee_count - Enum.count(active_pods)

            mentor.desired_mentee_count ->
              mentor.desired_mentee_count - Enum.count(active_pods)

            true ->
              nil
          end,
        mentee_names:
          active_pods
          |> Enum.map(& &1.mentee)
          |> Enum.reject(&is_nil/1)
          |> Enum.map(fn m -> m.name end)
          |> Enum.join(", "),
        counts:
          mentor.monthly_hour_counts
          |> Enum.map(fn m ->
            %{
              month: m.month,
              month_name: m.month_name |> humanize,
              year: m.year,
              hours: m.hours |> Decimal.round(1),
              time_sort_key: m.year * 1_000_000 + m.month * 1000 + (m.hours |> Decimal.to_float())
            }
          end)
          |> Enum.sort_by(fn m -> m.time_sort_key end),
        admin_path: Routes.admin_mentor_path(conn, :show, mentor)
      }
    end)
    |> Enum.sort_by(
      fn mentor ->
        most_recent_count = mentor.counts |> List.last()

        if most_recent_count do
          most_recent_count |> Map.get(:time_sort_key)
        else
          0
        end
      end,
      :desc
    )
  end

  def format_date(date) do
    case Timex.format(date, "%b %d %Y %l:%M %p", :strftime) do
      {:ok, formatted} -> formatted
      {:error, _} -> date
      _ -> "N/A"
    end
  end

  # [
  # %{hours: 13.25, month: 11, month_name: "November", pay: 530.0, year: 2020},
  # %{hours: 16.5, month: 1, month_name: "January", pay: 660.0, year: 2021},
  # ]
  def hour_counts_by_month(timesheet_entries) do
    timesheet_entries
    |> Enum.group_by(fn tse = %TimesheetEntry{} ->
      {tse.started_at.year, tse.started_at.month}
    end)
    |> Enum.map(fn {{year, month}, entries} ->
      hours_for_month =
        entries
        |> Enum.map(fn entry ->
          seconds = NaiveDateTime.diff(entry.ended_at, entry.started_at)

          seconds / 3600.0
        end)
        |> Enum.sum()

      pay_for_month =
        entries
        |> Enum.map(fn entry ->
          seconds = NaiveDateTime.diff(entry.ended_at, entry.started_at)

          seconds / 3600.0 * Decimal.to_float(entry.hourly_rate)
        end)
        |> Enum.sum()

      %{
        year: year,
        month: month,
        month_name: Timex.month_name(month),
        pay: Decimal.from_float(pay_for_month) |> Decimal.round(2),
        hours: hours_for_month
      }
    end)
  end
end
