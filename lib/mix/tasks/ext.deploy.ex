defmodule Mix.Tasks.Ext.Deploy do
  use Mix.Task
  alias Mix.Helper
  alias Mix.Commands.Deploy

  def run([env_name] = args) when length(args) == 1 do
    run([env_name, Helper.lookup_image_tag(), false])
  end

  def run([env_name, x]) when x == "-f" do
    run([env_name, Helper.lookup_image_tag(), x])
  end

  def run([env_name, image_tag]) do
    run([env_name, image_tag, false])
  end

  def run([env_name, image_tag, is_fast]) do
    HTTPoison.start()
    Helper.puts("Deploy service #{Mix.Project.config()[:app]}. Environment=#{env_name}. Image=#{image_tag}")

    env_name
    |> Deploy.Context.init(image_tag)
    |> Deploy.BuildArgs.call(is_fast)
    |> Deploy.FindOrCreateBuild.call()
    |> SendSlackNotification.call(:before)
    |> exec_shell()
    |> SendSlackNotification.call(:after)
  end

  defp exec_shell(%{args: args} = context) do
    Ext.Shell.exec(System.find_executable("ansible-playbook"), args, [{:line, 4096}])
    context
  end
end
