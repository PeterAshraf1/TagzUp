# This file is responsible for configuring your application
# and its dependencies with the aid of the Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
import Config

config :tagzup,
  ecto_repos: [TagzUp.Repo],
  ash_domains: [TagzUp.Accounts, TagzUp.Creators, TagzUp.Business, TagzUp.Bookings]

# Configures the endpoint
config :tagzup, TagzUpWeb.Endpoint,
  url: [host: "localhost"],
  adapter: Bandit.PhoenixAdapter,
  render_errors: [
    formats: [html: TagzUpWeb.ErrorHTML, json: TagzUpWeb.ErrorJSON],
    layout: false
  ],
  pubsub_server: TagzUp.PubSub,
  live_view: [signing_salt: "J5rwwFay"]

# Configures the mailer
#
# By default it uses the "Local" adapter which stores the emails
# locally. You can see the emails in your browser, at "/dev/mailbox".
#
# For production it's recommended to configure a different adapter
# at the `config/runtime.exs`.
config :tagzup, TagzUp.Mailer, adapter: Swoosh.Adapters.Local

# Configure esbuild (the version is required)
config :esbuild,
  version: "0.17.11",
  tagzup: [
    args:
      ~w(js/app.js --bundle --target=es2017 --outdir=../priv/static/assets --external:/fonts/* --external:/images/*),
    cd: Path.expand("../assets", __DIR__),
    env: %{"NODE_PATH" => Path.expand("../deps", __DIR__)}
  ]

# Configure tailwind (the version is required)
config :tailwind,
  version: "3.4.3",
  tagzup: [
    args: ~w(
      --config=tailwind.config.js
      --input=css/app.css
      --output=../priv/static/assets/app.css
    ),
    cd: Path.expand("../assets", __DIR__)
  ]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Configure Ash
config :ash, :include_embedded_source_by_default?, false

# Configure Oban
config :tagzup, Oban,
  engine: Oban.Engines.Basic,
  queues: [default: 10, verification: 5, emails: 2],
  repo: TagzUp.Repo
  
# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{config_env()}.exs"
