defmodule TznWeb.MentorPlug do

  def load_my_mentees(conn, _) do
    case Transizion.list_mentees(%{mentor: conn.assigns.current_user}) |> Repo.preload(:hour_counts) do
      {:ok, mentees} ->
      
      {:error} -> 
  end
end
