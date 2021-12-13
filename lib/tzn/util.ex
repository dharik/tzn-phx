defmodule Tzn.Util do
  def map_ids(e) do
    e |> Enum.map(& &1[:id])
  end
end
