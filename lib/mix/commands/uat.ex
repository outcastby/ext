defmodule Mix.Commands.Uat do
  def call() do
    Mix.Tasks.Ext.Deploy.run(["uat"])
  end
end
