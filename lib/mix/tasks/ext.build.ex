defmodule Mix.Tasks.Ext.Build do
  use Mix.Task
  import Mix.Ecto

  @doc false
  def run(args) do
    Utils.puts("Build service arcade")
    {branch, _} = System.cmd("git", ["symbolic-ref", "--short", "-q", "HEAD"])

    image_name = Utils.lookup_image_name(args && List.first(args))

    Utils.puts "Building 'arcade' branch is '#{branch}'"
    Utils.puts "Building 'arcade' Docker image as '#{image_name}'"

    Shell.exec(
      System.find_executable("docker"),
      ["build", "--build-arg", "CLONE_BRANCH=#{branch}", "-f", Utils.repos().dockerfile, "-t", image_name, "."],
      [{:line, 4096}]
    )

    Utils.puts "Pushing '#{image_name}' image into registry"
    Shell.exec(System.find_executable("docker"), ["push", image_name], [{:line, 4096}])
  end
end
