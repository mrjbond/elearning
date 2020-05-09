# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.

# General application configuration
use Mix.Config

config :kv_api,
  ecto_repos: [KvApi.Repo]

# Configures the endpoint
config :kv_api, KvApiWeb.Endpoint,
  url: [host: "localhost"],
  secret_key_base: "Q+sOKHTkG0l7ct7x0xprH5kRB3yvEo3wSGQmcn01IUkWItStgOkuhQy8b3h5gsJ/",
  render_errors: [view: KvApiWeb.ErrorView, accepts: ~w(json), layout: false],
  pubsub_server: KvApi.PubSub,
  live_view: [signing_salt: "aUt717It"]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

# Use Jason for JSON parsing in Phoenix
config :phoenix, :json_library, Jason

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env()}.exs"
