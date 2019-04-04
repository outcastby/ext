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
        result =
          ["author", "hash", "message", "last_commit_date", "image_name", "image_build_date"]
          |> Enum.reduce(%{last_commit: %{}, image: %{}}, fn key, result ->
            value =
              case key do
                "author" ->
                  {val, 0} = System.cmd("git", ["--no-pager", "show", "-s", "--format='%an <%ae>'"])
                  val |> String.replace(["\n", "'"], "")

                "hash" ->
                  {val, 0} = System.cmd("git", ["--no-pager", "show", "-s", "--format='%H'"])
                  val |> String.replace(["\n", "'"], "")

                "message" ->
                  {val, 0} = System.cmd("git", ["--no-pager", "show", "-s", "--format='%s'"])
                  val |> String.replace(["\n", "'"], "")

                "last_commit_date" ->
                  {val, 0} = System.cmd("git", ["--no-pager", "show", "-s", "--format='%ad'"])
                  val |> String.replace(["\n", "'"], "")

                "image_name" ->
                  image_name

                "image_build_date" ->
                  Timex.format!(Timex.now(), "{ANSIC}")
              end

            parent = if Enum.member?(["image_name", "image_build_date"], key), do: :image, else: :last_commit
            Map.put(result, parent, Map.put(result[parent], key, value))
          end)

        File.write(Application.get_env(Mix.Project.config()[:app], :ext)[:build_info_file_name], Poison.encode!(result))

      true ->
        nil
    end
  end
end
