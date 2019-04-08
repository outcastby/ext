defmodule Mix.Tasks.Ext.Build do
  use Mix.Task
  alias Mix.Helper

  @doc false
  def run(args) do
    Helper.puts("Build service #{Mix.Project.config()[:app]}")
    {branch, _} = System.cmd("git", ["symbolic-ref", "--short", "-q", "HEAD"])

    image_name = Helper.lookup_image_name(args && List.first(args))

    Helper.puts("Building '#{Mix.Project.config()[:app]}' branch is '#{branch}'")
    Helper.puts("Building '#{Mix.Project.config()[:app]}' Docker image as '#{image_name}'")

    write_build_info_file(image_name)

    Ext.Shell.exec(
      System.find_executable("docker"),
      ["build", "-f", Helper.settings()[:docker_file], "-t", image_name, "."],
      [{:line, 4096}]
    )

    Helper.puts("Pushing '#{image_name}' image into registry")
    Ext.Shell.exec(System.find_executable("docker"), ["push", image_name], [{:line, 4096}])
  end

  defp write_build_info_file(image_name) do
    file = Application.get_env(Mix.Project.config()[:app], :ext)[:build_info_file_name]

    cond do
      file ->
        result = %{
          image: %{
            name: image_name,
            build_date: Timex.format!(Timex.now(), "{ANSIC}"),
            build_author: build_author()
          },
          commit: %{
            date: commit_date(),
            message: commit_message(),
            hash: commit_hash(),
            author: commit_author()
          }
        }

        File.write(Application.get_env(Mix.Project.config()[:app], :ext)[:build_info_file_name], Poison.encode!(result))

      true ->
        nil
    end
  end

  def build_author do
    {val, 0} = System.cmd("whoami", [])
    val |> String.replace(["\n", "'"], "")
  end

  def commit_author do
    {val, 0} = System.cmd("git", ["--no-pager", "show", "-s", "--format='%an <%ae>'"])
    val |> String.replace(["\n", "'"], "")
  end

  def commit_hash do
    {val, 0} = System.cmd("git", ["--no-pager", "show", "-s", "--format='%h'"])
    val |> String.replace(["\n", "'"], "")
  end

  def commit_message do
    {val, 0} = System.cmd("git", ["--no-pager", "show", "-s", "--format='%s'"])
    val |> String.replace(["\n", "'"], "")
  end

  def commit_date do
    {val, 0} = System.cmd("git", ["--no-pager", "show", "-s", "--format='%at'"])

    val
    |> String.replace(["\n", "'"], "")
    |> String.to_integer()
    |> DateTime.from_unix!()
    |> Timex.format!("{ANSIC}")
  end
end
