defmodule Mix.Commands.Staging do
  def call(_flags \\ nil)

  def call("f") do
    Mix.Tasks.Ext.Deploy.run(["staging", "-f"])
  end

  def call(_flags) do
    Mix.Tasks.Ext.Deploy.run(["staging"])
  end
end
