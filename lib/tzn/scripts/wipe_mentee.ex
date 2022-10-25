defmodule Tzn.Scripts.WipeMentee do
  def wipe(mentee_id) do
    mentee = Tzn.Mentee.get_mentee!(mentee_id)
    pods = Tzn.Pods.list_pods(mentee)

    Tzn.Repo.transaction(fn ->
      pods
      |> Enum.flat_map(fn p -> p.contract_purchases end)
      |> Enum.each(fn cp -> {:ok, _} = Tzn.Transizion.delete_contract_purchase(cp) end)

      {:ok, _} = Tzn.Mentee.delete_mentee(mentee)
    end)
  end
end
