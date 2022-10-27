defmodule TznWeb.PlugAttack do
  use PlugAttack
  import Plug.Conn
  require Logger

  rule "block PHP vuln scanners", conn do
    ip_as_string = conn.remote_ip |> :inet.ntoa() |> to_string()
    if Regex.match?(~r/\.php$|\/wp-admin|\/wp-content/i, conn.request_path) do
      Logger.warn(
        "Banning #{ip_as_string} because they look like a vuln scanner"
      )

      Cachex.put(:ban_hammer, conn.remote_ip, :banned, ttl: :timer.minutes(60 * 24 * 3))
    end

    case Cachex.get(:ban_hammer, conn.remote_ip) do
      {:ok, :banned} ->
        # Change to debug after it looks good on prod
        Logger.info("Request blocked because #{ip_as_string} was previously banned")
        {:block, :php_vuln_scanner}

      {:ok, nil} ->
        {:allow, :dontcare}
    end
  end

  def block_action(conn, :php_vuln_scanner, _opts) do
    conn
    |> send_resp(:ok, "successful login\n")
    |> halt
  end

  def block_action(conn, _data, _opts) do
    conn
    |> send_resp(:forbidden, "Forbidden\n")
    |> halt
  end
end
