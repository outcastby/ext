defmodule Mix.Tasks.Ext.Build do
  use Mix.Task
  alias Mix.Helper

  @doc false
  def run(args) do
    Helper.puts("Build service arcade")
    {branch, _} = System.cmd("git", ["symbolic-ref", "--short", "-q", "HEAD"])

    image_name = Helper.lookup_image_name(args && List.first(args))

    Helper.puts("Building 'arcade' branch is '#{branch}'")
    Helper.puts("Building 'arcade' Docker image as '#{image_name}'")

    Shell.exec(
      System.find_executable("docker"),
      ["build", "--build-arg", "CLONE_BRANCH=#{branch}", "-f", Helper.settings().docker_file, "-t", image_name, "."],
      [{:line, 4096}]
    )

    Helper.puts("Pushing '#{image_name}' image into registry")
    Shell.exec(System.find_executable("docker"), ["push", image_name], [{:line, 4096}])
  end
end
