defmodule Mix.Commands.Staging do
  def call() do
    Mix.Tasks.ExtDeploy.run(["staging"])
  end
end
