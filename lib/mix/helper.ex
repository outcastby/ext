defmodule Mix.Helper do
  @available_commands ["build", "staging", "uat", "prod"]
  @depends_of_build_commands ["staging", "uat", "prod"]
  @auto_built_branches ["develop", "master", "release", "hotfix"]

  def puts(text, color \\ :green), do: [:black_background, color, text] |> IO.ANSI.format() |> IO.puts()
  def write(text, color \\ :green), do: [:black_background, color, text] |> IO.ANSI.format() |> IO.write()

  def lookup_image_name(tag \\ nil), do: "#{settings()[:docker_image]}:#{tag || lookup_image_tag()}"

  def lookup_image_tag do
    {hash, _} = System.cmd("git", ["rev-parse", "--short", "HEAD"])

    "#{lookup_branch()}-#{hash |> String.trim()}-#{Timex.format!(Timex.now(), "%d%b", :strftime)}"
  end

  def lookup_branch do
    {branch, _} = System.cmd("git", ["symbolic-ref", "--short", "-q", "HEAD"])
    branch = branch |> String.trim() |> String.replace("/", "_")

    cond do
      branch == "develop" -> "dev"
      true -> branch
    end
  end

  def lookup_commands_from_commit_message do
    {message, _} = System.cmd("git", ["log", "-1", "--pretty=%B"])

    message
    |> String.split("\n\n")
    |> Enum.filter(&(&1 != ""))
    |> List.last()
    |> String.split("/")
    |> Enum.map(&String.split(&1, "~"))
    |> Enum.filter(&Enum.member?(@available_commands, List.first(&1)))
    |> enhance_by_default_commands()
  end

  def enhance_by_default_commands(commands) do
    branch = lookup_branch()

    commands =
      if Enum.any?(commands, &(List.first(&1) in @depends_of_build_commands)) do
        [["build"]] ++ commands
      else
        commands
      end

    commands =
      if Enum.any?(@auto_built_branches, &(branch =~ &1)) do
        [["build"]] ++ commands
      else
        commands
      end

    commands |> Enum.uniq_by(&List.first(&1))
  end

  def settings do
    Application.get_env(Mix.Project.config()[:app], :ext, [])
  end
end
