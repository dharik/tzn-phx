defmodule Tzn.Transizion.ContractPurchase do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contract_purchases" do
    belongs_to :mentee, Tzn.Transizion.Mentee # TODO: Remove since we'll move to pod
    belongs_to :pod, Tzn.DB.Pod
    field :hours, :decimal
    field :date, :naive_datetime
    field :notes, :string
    timestamps()
  end

  def changeset(contract_purchase, attrs) do
    contract_purchase
    |> cast(attrs, [:hours, :date, :notes, :pod_id])
    |> validate_required([:hours, :date])
    |> foreign_key_constraint(:pod_id)
  end
end
