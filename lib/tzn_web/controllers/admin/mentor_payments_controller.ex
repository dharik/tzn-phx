defmodule TznWeb.Admin.MentorPaymentsController do
  use TznWeb, :controller

  alias Tzn.Transizion
  alias Tzn.Repo
  require IEx

  def index(conn, %{
        "start_year" => start_year,
        "start_month" => start_month,
        "end_year" => end_year,
        "end_month" => end_month
      }) do
    render(conn, "index.html",
      mentors:
        mentor_data(
          start_year |> String.to_integer(),
          start_month |> String.to_integer(),
          end_year |> String.to_integer(),
          end_month |> String.to_integer()
        )
    )
  end

  def index(conn, _params) do
    current_year = Timex.now().year
    current_month = Timex.now().month

    conn
    |> redirect(
      to:
        Routes.admin_mentor_payments_path(conn, :index, %{
          start_year: current_year,
          start_month: current_month,
          end_year: current_year,
          end_month: current_month
        })
    )
    |> halt()
  end

  defp mentor_data(start_year, start_month, end_year, end_month) do
    filter_start = Timex.beginning_of_month(start_year, start_month)

    filter_end =
      Timex.end_of_month(end_year, end_month)
      |> Timex.to_datetime()
      |> Timex.end_of_day()

    Transizion.list_mentors()
    |> Repo.preload([:timesheet_entries])
    |> Enum.reject(fn mentor -> mentor.archived end)
    |> Enum.map(fn mentor ->
      %{
        name: mentor.name,
        id: mentor.id,
        payment:
          mentor.timesheet_entries
          |> Enum.filter(fn tse ->
            Timex.between?(tse.started_at, filter_start, filter_end, inclusive: true)
          end)
          |> Enum.map(fn tse ->
            seconds = NaiveDateTime.diff(tse.ended_at, tse.started_at)
            seconds / 3600.0 * Decimal.to_float(tse.hourly_rate)
          end)
          |> Enum.sum()
      }
    end)
  end
end
