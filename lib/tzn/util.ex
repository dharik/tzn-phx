defmodule Tzn.Util do
  def map_ids(e) do
    e |> Enum.map(& &1[:id])
  end

  def format_date_relative(date) do
    Timex.Format.DateTime.Formatters.Relative.format!(date, "{relative}")
  end

  def within_n_days_ago(nil, _) do
    false
  end
  def within_n_days_ago(date, n) do
    date |> Timex.after?(Timex.shift(Timex.now(), days: -n))
  end

  def within_n_hours_ago(nil, _) do
    false
  end
  def within_n_hours_ago(date, n) do
    date |> Timex.after?(Timex.shift(Timex.now(), hours: -n))
  end

  def diff_in_hours(time1, time2, places \\ 2) do
    Timex.diff(time1, time2, :duration)
    |> Timex.Duration.to_hours()
    |> Number.Conversion.to_decimal()
    |> Decimal.round(places)
  end

  def grade_options do
    [
      {"Middle school", "middle_school"},
      {"Freshman", "freshman"},
      {"Sophomore", "sophomore"},
      {"Junior", "junior"},
      {"Senior", "senior"},
      {"College", "college"}
    ]
  end

  def humanize_grade(grade_slug) do
    # TODO
  end

  def slugify_grade(humanized_grade) do
    # TODO
  end
end
