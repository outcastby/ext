defmodule Mix.Commands.Uat do
  def call() do
    Mix.Tasks.ExtDeploy.run(["uat"])
  end
end
