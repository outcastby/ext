defmodule Mix.Commands.Uat do
  def call(_flags \\ nil)
  def call("f") do
    Mix.Tasks.Ext.Deploy.run(["uat", "-f"])
  end

  def call(_flags) do
    Mix.Tasks.Ext.Deploy.run(["uat"])
  end
end
