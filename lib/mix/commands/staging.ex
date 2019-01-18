defmodule Mix.Commands.Staging do
  def call() do
    Mix.Tasks.Ext.Deploy.run(["staging"])
  end
end
