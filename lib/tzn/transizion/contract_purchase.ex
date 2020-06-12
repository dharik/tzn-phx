defmodule Tzn.Transizion.ContractPurchase do
  use Ecto.Schema
  import Ecto.Changeset

  schema "mentees" do
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
    |> cast(attrs, [:hours, :date, :notes])
    |> validate_required([:hours, :date, :notes])
  end
end
