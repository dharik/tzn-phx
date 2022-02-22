defmodule Tzn.Emails.EmailHistory do
  use Ecto.Schema
  import Ecto.Changeset

  schema "email_history" do
    field :email_address, :string
    field :key, :string
    field :sent_at, :naive_datetime
  end

  def changeset(e, attrs) do
    e
    |> cast(attrs, [:email_address, :key, :sent_at])
    |> validate_required([:email_address, :key, :sent_at])
  end
end
