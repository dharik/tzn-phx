defmodule TznWeb.Admin.PodView do
  use TznWeb, :view

  def format_date(date) do
    case Timex.format(date, "%b %d %l:%M %p", :strftime) do
      {:ok, formatted} -> formatted
      {:error, _} -> date
      _ -> "N/A"
    end
  end

  def sort_todos(todos) do
    Enum.sort_by(todos, fn todo ->
      cond do
        todo.deleted_at -> {-1, todo.inserted_at |> Timex.to_unix()}
        todo.completed -> {0, todo.inserted_at |> Timex.to_unix()}
        true -> {1, todo.inserted_at |> Timex.to_unix()}
      end
    end) |> Enum.reverse()
  end
end
