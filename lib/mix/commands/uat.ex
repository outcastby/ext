defmodule Mix.Commands.Uat do
  require IEx
  require Logger

  def call() do
    Mix.Tasks.ExtDeploy.run(["uat"])
  end
end
