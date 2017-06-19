defmodule Reph.Mixfile do
  use Mix.Project

  def project do
    [app: :reph,
     start_permanent: Mix.env == :prod,
     version: "0.1.0",
     elixir: "~> 1.3 or ~> 1.4"]
  end

  # Configuration for the OTP application
  #
  # Type `mix help compile.app` for more information
  def application do
    [extra_applications: []]
  end
end
