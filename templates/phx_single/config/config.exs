# This file is responsible for configuring your application
# and its dependencies with the aid of the Mix.Config module.
#
# This configuration file is loaded before any dependency and
# is restricted to this project.
use Mix.Config

<%= if namespaced? || ecto || generators do %># General application configuration
config :<%= app_name %><%= if namespaced? do %>,
  namespace: <%= app_module %><% end %><%= if ecto do %>,
  ecto_repos: [<%= app_module %>.Repo]<% end %><%= if generators do %>,
  generators: <%= inspect generators %><% end %>

<% end %># Configures the endpoint
config :<%= app_name %>, <%= endpoint_module %>,
  url: [host: "localhost"],
  secret_key_base: "<%= secret_key_base %>",
  render_errors: [view: <%= web_namespace %>.ErrorView, accepts: ~w(html json)],
  pubsub: [name: <%= app_module %>.PubSub,
           adapter: Phoenix.PubSub.PG2]

# Configures Elixir's Logger
config :logger, :console,
  format: "$time $metadata[$level] $message\n",
  metadata: [:request_id]

config :std_json_io,
  pool_size: 10,
  pool_max_overflow: 10,
  script: "assets/node_modules/.bin/react-stdio"

# Import environment specific config. This must remain at the bottom
# of this file so it overrides the configuration defined above.
import_config "#{Mix.env}.exs"
