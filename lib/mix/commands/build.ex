defmodule Mix.Commands.Build do
  def call(_flags \\ nil) do
    Mix.Tasks.Ext.Build.run([])
  end
end
