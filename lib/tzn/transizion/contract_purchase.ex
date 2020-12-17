defmodule Tzn.Transizion.ContractPurchase do
  use Ecto.Schema
  import Ecto.Changeset

  schema "contract_purchases" do
    belongs_to :mentee, Tzn.Transizion.Mentee
    field :hours, :decimal
    field :date, :naive_datetime
    field :notes, :string
    timestamps()
  end

  # Admin changeset
  @doc false
  def changeset(contract_purchase, attrs) do
    contract_purchase
    |> cast(attrs, [:hours, :date, :notes, :mentee_id])
    |> validate_required([:hours, :date, :mentee_id])
    |> cast_assoc(:mentee)
  end
end
