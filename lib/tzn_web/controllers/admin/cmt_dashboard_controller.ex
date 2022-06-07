defmodule TznWeb.Admin.CmtDashboardController do
  use TznWeb, :controller

  def show(conn, _params) do
    token =
      TznWeb.MetabaseToken.generate_and_sign!(
        %{
          resource: %{dashboard: 2},
          params: %{},
          exp: (Timex.now() |> Timex.to_unix()) + 60 * 10
        },
        Joken.Signer.create(
          "HS256",
          Application.get_env(:tzn, :metabase_secret)
        )
      )


    render(conn, "show.html", token: token)
  end


end
