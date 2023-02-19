defmodule Tzn.MixProject do
  use Mix.Project

  def project do
    [
      app: :tzn,
      version: "0.1.0",
      elixir: "~> 1.7",
      elixirc_paths: elixirc_paths(Mix.env()),
      compilers: [:phoenix] ++ Mix.compilers(),
      start_permanent: Mix.env() == :prod,
      aliases: aliases(),
      deps: deps()
    ]
  end

  # Configuration for the OTP application.
  #
  # Type `mix help compile.app` for more information.
  def application do
    [
      mod: {Tzn.Application, []},
      extra_applications: [:logger, :runtime_tools, :bugsnag]
    ]
  end

  # Specifies which paths to compile per environment.
  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Specifies your project dependencies.
  #
  # Type `mix help deps` for examples and options.
  defp deps do
    [
      {:phoenix, "~> 1.6.0"},
      {:phoenix_ecto, "~> 4.1"},
      {:plugsnag, "~> 1.4.0"},
      {:ecto_sql, "~> 3.4"},
      {:postgrex, ">= 0.0.0"},
      {:phoenix_html, "~> 3.0"},
      {:phoenix_live_reload, "~> 1.2", only: :dev},
      {:phoenix_live_dashboard, "~> 0.5"},
      {:phoenix_live_view, "~> 0.17.6"},
      {:telemetry_metrics, "~> 0.6"},
      {:telemetry_poller, "~> 0.5"},
      {:timex, "~> 3.5"},
      {:gettext, "~> 0.11"},
      {:jason, "~> 1.0"},
      {:plug_cowboy, "~> 2.0"},
      {:pow, "~> 1.0.26"},
      {:pow_postgres_store, "~> 1.0"},
      {:quantum, "~> 3.0"},
      {:httpoison, "~> 1.6"},
      {:number, "~> 1.0.3"},
      {:react_phoenix, "~> 1.3"},
      {:html_sanitize_ex, "~> 1.4"},
      {:shortuuid, "~> 2.0"},
      {:swoosh, "~> 1.5"},
      {:phoenix_swoosh, "~> 1.0"},
      {:ex_aws, "~> 2.2.9"},
      {:ex_aws_s3, "~> 2.3.2"},
      {:sweet_xml, "~> 0.7.2"},
      {:floki, "~> 0.32.1"},
      {:joken, "~> 2.4"},
      {:the_fuzz, "~> 0.5.0"},
      {:calibex, "~> 0.1.0"},
      {:esbuild, "~> 0.5", runtime: Mix.env() == :dev},
      {:dart_sass, "~> 0.5", runtime: Mix.env() == :dev},
      {:tailwind, "~> 0.1", runtime: Mix.env() == :dev},
      {:accent, "~> 1.1"},
      {:cachex, "~> 3.4"},
      {:plug_attack, "~> 0.4.2"},
      {:plug_forwarded_peer, "~> 0.0.2"},
      {:ex_audit, "~> 0.9"}
    ]
  end

  # Aliases are shortcuts or tasks specific to the current project.
  # For example, to install project dependencies and perform other setup tasks, run:
  #
  #     $ mix setup
  #
  # See the documentation for `Mix` for more info on aliases.
  defp aliases do
    [
      setup: ["deps.get", "ecto.setup"],
      "ecto.setup": ["ecto.create", "ecto.migrate", "run priv/repo/seeds.exs"],
      "ecto.reset": ["ecto.drop", "ecto.setup"],
      test: ["ecto.create --quiet", "ecto.migrate --quiet", "test"],
      "assets.deploy": ["esbuild default --minify", "esbuild school_admin --minify", "sass default", "tailwind default --minify", "phx.digest"]
    ]
  end
end
