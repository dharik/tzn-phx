defmodule Tzn.Repo.Migrations.AddPurchasePriceToContractPurchases do
  use Ecto.Migration

  def change do
    alter table(:contract_purchases) do
      add :expected_revenue, :decimal
    end
  end
end
