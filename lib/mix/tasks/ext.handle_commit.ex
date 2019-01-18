defmodule Mix.Tasks.Ext.HandleCommit do
  use Mix.Task
  alias Mix.Helper

  @shortdoc "Handle commit message"

  @moduledoc """
  Parse last commit message. If on last row we detect commands, we trigger them

  Examples:

  build
  uat/staging
  """

  @doc false
  def run(_args) do
    commands = Helper.lookup_commands_from_commit_message()
    Helper.puts("Follow commands will be processed by comment message: #{inspect(commands)}")

    commands
    |> Enum.each(fn command ->
      apply("Elixir.Mix.Commands.#{String.capitalize(command)}" |> String.to_existing_atom(), :call, [])
    end)
  end
end
