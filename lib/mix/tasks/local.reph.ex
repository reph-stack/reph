defmodule Mix.Tasks.Local.Reph do
  use Mix.Task

  @url "https://github.com/reph-stack/reph/archives/raw/master/reph_new.ez"
  @shortdoc "Updates the Reph project generator locally"

  @moduledoc """
  Updates the Reph project generator locally.

      mix local.reph

  Accepts the same command line options as `archive.install`.
  """
  def run(args) do
    Mix.Task.run "archive.install", [@url | args]
  end
end
