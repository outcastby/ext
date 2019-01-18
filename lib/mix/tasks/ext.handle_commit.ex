defmodule Mix.Tasks.Ext.HandleCommit do
  use Mix.Task
  import Mix.Ecto

  @shortdoc "Handle commit message"

  @moduledoc """
  Parse last commit message. If on last row we detect commands, we trigger them

  Examples:

  build
  uat/staging
  """

  @doc false
  def run(_args) do
    commands = Utils.lookup_commands_from_commit_message()
    Utils.puts("Follow commands will be processed by comment message: #{commands}")

    commands
    |> Enum.each(fn command ->
      apply(String.to_existing_atom("Elixir.Mix.Commands.#{String.capitalize(command)}"), :call, [])
    end)
  end
end
