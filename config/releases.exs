import Config

config :tzn, sendgrid_auth: System.get_env("SENDGRID_AUTH_HEADER")

config :tzn, Tzn.Mailer,
  adapter: Swoosh.Adapters.Sendgrid,
  api_key: System.get_env("SENDGRID_API_KEY")
