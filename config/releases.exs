import Config

config :tzn, TznWeb.Endpoint,
  server: true,
  http: [port: {:system, "PORT"}],
  url: [host: nil, port: 443]

config :tzn, sendgrid_auth: System.get_env("SENDGRID_AUTH_HEADER")