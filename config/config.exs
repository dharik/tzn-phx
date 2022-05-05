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

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

config :pow, Pow.Postgres.Store,
  repo: Tzn.Repo

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
  {"0 */1 * * *",         {Tzn.Jobs.CleanupPodChanges, :run, []}},
  {"0 */1 * * *",         {Tzn.Jobs.CleanupMenteeChanges, :run, []}},
  {"0 0 */1 * *",         {Tzn.Jobs.ParentUpdateEmails, :todo_list_changed, []}},
  {"0 0 */15 * *",         {Tzn.Jobs.ParentUpdateEmails, :biweekly_minimum, []}}
]

config :bugsnag,
  api_key: "78ca1a1066750db225de5e66c4c29bad"

config :tzn, allow_impersonating_admins: false

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
