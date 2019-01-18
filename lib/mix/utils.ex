defmodule Mix.Utils do
  require IEx
  require Logger

  @available_commands ["build", "staging", "uat", "prod"]
  @depends_of_build_commands ["staging", "uat", "prod"]
  @auto_built_branches ["develop", "master", "release", "hotfix"]

  def puts(text, color \\ :green), do: [:black_background, color, inspect(text)] |> IO.ANSI.format() |> IO.puts()

  def lookup_image_name(tag \\ nil), do: "#{settings().image}:#{tag || lookup_image_tag()}"

  def lookup_image_tag do
    {hash, _} = System.cmd("git", ["rev-parse", "--short", "HEAD"])

    "v.#{lookup_branch()}-#{hash |> String.trim()}"
  end

  def lookup_branch do
    {branch, _} = System.cmd("git", ["symbolic-ref", "--short", "-q", "HEAD"])
    branch |> String.trim() |> String.replace("/", "_")
  end

  def lookup_commands_from_commit_message do
    {message, _} = System.cmd("git", ["log", "-1", "--pretty=%B"])

    message
    |> String.split("\n\n")
    |> Enum.filter(&(&1 != ""))
    |> List.last()
    |> String.split("/")
    |> Enum.filter(&Enum.member?(@available_commands, &1))
    |> enhance_by_default_commands()
  end

  def enhance_by_default_commands(commands) do
    branch = lookup_branch()

    commands =
      if Enum.any?(commands, &(&1 in @depends_of_build_commands)) do
        commands ++ ["build"]
      end

    commands =
      if Enum.any?(@auto_built_branches, &(branch =~ &1)) do
        commands ++ ["build"]
      end

    commands |> Enum.uniq()
  end

  def settings do
    Application.get_env(Mix.Project.config()[:app], :ecto_repos, [])
  end
end
