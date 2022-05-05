defmodule Tzn.Transizion.ContractPurchase do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contract_purchases" do
    belongs_to :pod, Tzn.DB.Pod
    field :hours, :decimal
    field :date, :naive_datetime
    field :notes, :string
    field :expected_revenue, :decimal
    timestamps()
  end

  def changeset(contract_purchase, attrs) do
    contract_purchase
    |> cast(attrs, [:hours, :date, :notes, :pod_id, :expected_revenue])
    |> validate_required([:hours, :date, :expected_revenue])
    |> validate_number(:expected_revenue, greater_than_or_equal_to: 0)
    |> validate_number(:expected_revenue, less_than: 100000)
    |> foreign_key_constraint(:pod_id)
  end
end
