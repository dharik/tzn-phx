defmodule Tzn.Util do
  alias Tzn.Transizion.{Mentee, Mentor}

  def map_ids(e) do
    e |> Enum.map(& &1.id)
  end

  def to_initials(name) when is_binary(name) do
    name |> String.split(" ") |> Enum.map(&String.first/1) |> Enum.join("") |> String.upcase()
  end

  def format_date_generic(date) do
      case Timex.format(date, "%b %d %Y %l:%M %p", :strftime) do
        {:ok, formatted} -> formatted
        {:error, _} -> date
        _ -> "N/A"
      end
    end

  def format_date_relative(date) do
    Timex.Format.DateTime.Formatters.Relative.format!(date, "{relative}")
  end

  def fomat_date_month_year(date) do
    case Timex.format(date, "%B %Y", :strftime) do
      {:ok, formatted} -> formatted
      {:error, _} -> "N/A"
      _ -> "N/A"
    end
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

  def grade_options(:high_school) do
    [
      {"Freshman", "freshman"},
      {"Sophomore", "sophomore"},
      {"Junior", "junior"},
      {"Senior", "senior"}
    ]
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

  def timezone_options do
    [
      {"Other/Unknown", nil},
      {"Brasilia", -3},
      {"New York", -4},
      {"Chicago", -5},
      {"Salt Lake City", -6},
      {"Los Angeles", -7},
      {"Alaska/USA", -8},
      {"Honolulu", -10},
      {"American Samoa", -11},
      {"Baker Island", -12}
    ]
  end

  def offset_to_timezone_city(offset) do
    {label, _} =
      Enum.find(timezone_options(), {"Unknown", nil}, fn {_label, offset_value} ->
        offset == offset_value
      end)

    label
  end

  def humanize_grade(_grade_slug) do
    # TODO
  end

  def slugify_grade(_humanized_grade) do
    # TODO
  end

  def humanize(str) when is_binary(str) do
    Phoenix.Naming.humanize(str)
  end

  def informal_name(nil) do
    ""
  end

  def informal_name(%Mentee{} = m) do
    if is_binary(m.nick_name) do
      m.nick_name
    else
      m.name
    end
  end

  def informal_name(%Mentor{} = m) do
    if is_binary(m.nick_name) do
      m.nick_name
    else
      m.name
    end
  end

  # Warning: This is high vulnerability. Be very careful.
  def make_hyperlinks(text) do
    Regex.replace(
      ~r/(http|https|ftp|ftps)\:\/\/[a-zA-Z0-9\-\.]+\.[a-zA-Z]{2,3}(\/\S*)?/,
      text,
      "<a href=\"\\0\" class=\"link\">\\0</a>"
    )
  end

  def pluralize(num, unit, unit_plural \\ nil) do
    if num == 1 do
      "#{num} #{unit}"
    else
      unit_plural = unit_plural || (unit <> "s")
      "#{num} #{unit_plural}"
    end
  end

  def find_by_id(col, id) when is_binary(id) do
    Enum.find(col, fn item -> item.id == String.to_integer(id) end)
  end

  def find_by_id(col, id) when is_integer(id) do
    Enum.find(col, fn item -> item.id == id end)
  end

  def find_by_id(col, nil), do: nil
end
