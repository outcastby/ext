defmodule Mix.Helper do
  @available_commands ["build", "staging", "uat", "prod"]
  @depends_of_build_commands ["staging", "uat", "prod"]
  @auto_built_branches ["develop", "dev", "master", "release", "hotfix"]

  def puts(text, color \\ :green), do: [:black_background, color, text] |> IO.ANSI.format() |> IO.puts()
  def write(text, color \\ :green), do: [:black_background, color, text] |> IO.ANSI.format() |> IO.write()

  def lookup_image_repository(), do: settings()[:docker_image]
  def lookup_image_name(tag \\ nil), do: "#{lookup_image_repository()}:#{tag || lookup_image_tag()}"

  def lookup_image_tag do
    {hash, _} = System.cmd("git", ["rev-parse", "--short", "HEAD"])
    branch_name = lookup_branch()

    cond do
      branch_name == "master" -> "#{branch_name}-#{tag_version()}"
      #      branch_name =~ ~r/^release/ -> "#{branch_name}-#{String.trim(hash)}"
      true -> "#{lookup_branch()}-#{String.trim(hash)}-#{lookup_date()}"
    end
  end

  def tag_version do
    {tag, _} = System.cmd("git", ["describe", "--abbrev=0", "--tags"])
    tag |> String.trim()
  end

  def lookup_date do
    {date, _} = System.cmd("git", ["log", "-1", "--format=%at"])
    date = date |> String.trim() |> String.to_integer()
    {:ok, datetime} = DateTime.from_unix(date)
    Timex.format!(datetime, "%d%b", :strftime)
  end

  def lookup_branch do
    {branch, _} = System.cmd("git", ["symbolic-ref", "--short", "-q", "HEAD"])
    branch = branch |> String.trim() |> String.replace("/", "-")

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
