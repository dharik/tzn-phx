defmodule TznWeb.Admin.MentorView do
  use TznWeb, :view

  def render("index.json", %{mentors: mentors, conn: conn}) do
    mentors
    |> Enum.map(fn mentor ->
      %{
        name: mentor.name,
        archived: mentor.archived,
        mentee_names:
          mentor.mentees
          |> Enum.reject(fn m -> m.archived end)
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
    case Timex.format(date, "%b %d %l:%M %p", :strftime) do
      {:ok, formatted} -> formatted
      {:error, _} -> date
      _ -> "N/A"
    end
  end
end
