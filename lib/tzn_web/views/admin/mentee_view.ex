defmodule TznWeb.Admin.MenteeView do
  use TznWeb, :view

  def low_hours_warning?(hours_used, hours_purchased) do
    hours_purchased - hours_used < 5
  end

  def format_date(date) do
    case Timex.format(date, "%b %d %l:%M %p", :strftime) do
      {:ok, formatted} -> formatted
      {:error, _} -> date
      _ -> "N/A"
    end
  end
end