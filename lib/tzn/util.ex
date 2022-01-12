defmodule Tzn.Util do
  def map_ids(e) do
    e |> Enum.map(& &1[:id])
  end

  def format_date_relative(date) do
    Timex.Format.DateTime.Formatters.Relative.format!(date, "{relative}")
  end

  def within_n_days_ago(date, n) do
    date |> Timex.after?(Timex.shift(Timex.now(), days: -n))
  end
end
