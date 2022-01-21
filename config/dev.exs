use Mix.Config

# Configure your database
config :tzn, Tzn.Repo,
  username: "postgres",
  password: "dev",
  database: "tzn_dev",
  hostname: "tzndb",
  show_sensitive_data_on_connection_error: true,
  pool_size: 2

# For development, we disable any cache and enable
# debugging and code reloading.
#
# The watchers configuration can be used to run external
# watchers to your application. For example, we use it
# with webpack to recompile .js and .css sources.
config :tzn, TznWeb.Endpoint,
  http: [port: 4000],
  debug_errors: true,
  code_reloader: true,
  check_origin: false,
  watchers: [
    node: [
      "node_modules/webpack/bin/webpack.js",
      "--mode",
      "development",
      "--watch-stdin",
      cd: Path.expand("../assets", __DIR__)
    ]
  ]

# ## SSL Support
#
# In order to use HTTPS in development, a self-signed
# certificate can be generated by running the following
# Mix task:
#
#     mix phx.gen.cert
#
# Note that this task requires Erlang/OTP 20 or later.
# Run `mix help phx.gen.cert` for more information.
#
# The `http:` config above can be replaced with:
#
#     https: [
#       port: 4001,
#       cipher_suite: :strong,
#       keyfile: "priv/cert/selfsigned_key.pem",
#       certfile: "priv/cert/selfsigned.pem"
#     ],
#
# If desired, both `http:` and `https:` keys can be
# configured to run both http and https servers on
# different ports.

# Watch static and templates for browser reloading.
config :tzn, TznWeb.Endpoint,
  live_reload: [
    patterns: [
      ~r"priv/static/.*(js|css|png|jpeg|jpg|gif|svg)$",
      ~r"priv/gettext/.*(po)$",
      ~r"lib/tzn_web/(live|views)/.*(ex)$",
      ~r"lib/tzn_web/templates/.*(eex)$"
    ]
  ]

# Do not include metadata nor timestamps in development logs
config :logger, :console, format: "[$level] $message\n"

# Set a higher stacktrace during development. Avoid configuring such
# in production as building large stacktraces may be expensive.
config :phoenix, :stacktrace_depth, 20

# Initialize plugs at runtime for faster development compilation
config :phoenix, :plug_init_mode, :runtime

config :bugsnag,
  release_stage: "development"

config :tzn, Tzn.Mailer,
  adapter: Swoosh.Adapters.Local

config :ex_aws,
  access_key_id: ["set in dev.secret.exs", :instance_role],
  secret_access_key: ["set in dev.secret.exs", :instance_role]

config :ex_aws, :s3,
  scheme: "https://",
  host: "nyc3.digitaloceanspaces.com",
  port: 443

config :tzn, s3_bucket: "collegerize-dev"

config :tzn, allow_impersonating_admins: true

import_config "dev.secret.exs"
