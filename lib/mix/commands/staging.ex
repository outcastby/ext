defmodule Mix.Commands.Staging do
  require IEx
  require Logger

  def call() do
    Mix.Tasks.ExtDeploy.run(["staging"])
  end
end
