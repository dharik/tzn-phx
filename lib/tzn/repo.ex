defmodule Tzn.Repo do
  use Ecto.Repo,
    otp_app: :tzn,
    adapter: Ecto.Adapters.Postgres
  use ExAudit.Repo

  import Ecto.Query


  def to_ids(items) do
    Enum.map(items, fn
      item when is_integer(item) -> item
      item when is_struct(item) -> item.id
      item when is_binary(item) -> String.to_integer(item)
    end)
  end

  def batch_get(ids_or_items, model) when is_list(ids_or_items) do
    if Enum.all?(ids_or_items, fn i -> is_struct(i, model) end) do
      ids_or_items
    else
      from(i in model, where: i.id in ^to_ids(ids_or_items)) |> all()
    end
  end

  def batch_get(item, model) when is_struct(item, model) do
    item
  end

  def batch_get(id, model) when is_integer(id) do
    get(model, id)
  end

  # TODO: ensure_assocs
  # if thing.assoc, go. Else Ecto.assoc(thing, :assoc)
end
