use Mix.Config

# We don't run a server during test. If one is required,
# you can enable the server option below.
config :<%= web_app_name %>, <%= endpoint_module %>,
  http: [port: 4001],
  server: false
