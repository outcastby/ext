defmodule Mix.Commands.Build do
  require IEx
  require Logger
  alias Mix.Utils

  def call() do
    Mix.Tasks.Ext.Build.run()
  end
end
