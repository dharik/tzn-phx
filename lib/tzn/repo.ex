defmodule Tzn.Repo do
  use Ecto.Repo,
    otp_app: :tzn,
    adapter: Ecto.Adapters.Postgres
end
