defmodule Mix.Commands.Uat do
  require IEx
  require Logger

  def call() do
    Mix.Tasks.Deploy.run(["uat"])
  end
end
