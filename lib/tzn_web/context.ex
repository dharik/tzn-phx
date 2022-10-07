defmodule TznWeb.Context do
  @behaviour Plug

  def init(opts), do: opts

  def call(conn, _) do
    Absinthe.Plug.put_options(conn,
      context: %{
        current_user:
          conn.assigns.current_user
          |> Tzn.Repo.preload([
            :school_admin_profile,
            :mentee_profile,
            :mentor_profile,
            :admin_profile,
            :parent_profile
          ]),
        loader: Dataloader.new() |> Dataloader.add_source(:db, Dataloader.Ecto.new(Tzn.Repo))
      }
    )
  end
end
