# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :tzn,
  ecto_repos: [Tzn.Repo]

# Configures the endpoint
config :tzn, TznWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "WpUeS4cTCcCzW7yIfIfU5g/w6zCSWzikfEgf4e1b66AKKhz7wMttsVDmWcavhlmh",
  render_errors: [view: TznWeb.ErrorView, accepts: ~w(html json), layout: false],
  pubsub_server: Tzn.PubSub,
  live_view: [signing_salt: "PBGPtlmC"]

config :mime, :types, %{
  "text/calendar" => ["ical"]
}

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :pow, Pow.Postgres.Store, repo: Tzn.Repo

config :tzn, :pow,
  user: Tzn.Users.User,
  repo: Tzn.Repo,
  extensions: [PowEmailConfirmation, PowResetPassword, PowPersistentSession],
  controller_callbacks: Pow.Extension.Phoenix.ControllerCallbacks,
  web_module: TznWeb,
  mailer_backend: Tzn.PowMailer,
  web_mailer_module: TznWeb,
  cache_store_backend: Pow.Postgres.Store

config :tzn, Tzn.Scheduler,
  jobs: [
    {"0 */1 * * *", {Tzn.Jobs.CleanupPodChanges, :run, []}},
    {"0 */1 * * *", {Tzn.Jobs.CleanupMenteeChanges, :run, []}},
    {"0 */1 * * *", {Tzn.Jobs.SyncMenteeGradeWithPodTimelines, :run, []}},
    {"0 0 */1 * *", {Tzn.Jobs.ParentUpdateEmails, :daily_checks, []}}
  ]

config :bugsnag,
  api_key: "78ca1a1066750db225de5e66c4c29bad"

config :tzn, allow_impersonating_admins: false

config :esbuild,
  version: "0.14.41",
  default: [
    args:
      ~w(./js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ],
  school_admin: [
    args:
      ~w(./js/school_admin/app.js --bundle --target=es2017 --outdir=../priv/static/assets/school_admin --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

config :dart_sass,
  version: "1.49.11",
  default: [
    # args: ~w(css/app.scss ../priv/static/assets/app.css),
    args: ~w(css/app.scss ../priv/static/assets/app.css.tailwind),
    cd: Path.expand("../assets", __DIR__)
  ]

config :tailwind,
  version: "3.1.8",
  default: [
    args: ~w(
    --config=tailwind.config.js
    --input=../priv/static/assets/app.css.tailwind
    --output=../priv/static/assets/app.css
  ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
