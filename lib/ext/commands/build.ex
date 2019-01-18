defmodule Ext.Commands.Build do
  def call() do
    Mix.Tasks.Ext.Build.run([])
  end
end
