defmodule Mix.Tasks.Ext.Deploy do
  use Mix.Task
  alias Mix.Helper

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
    Helper.puts("Deploy service #{Mix.Project.config()[:app]}. Environment=#{env_name}. Image=#{image_tag}")

    args = ["-i", "inventory", "playbook.yml", "--extra-vars", "env_name=#{env_name} image_tag=#{image_tag}"]

    args =
      if is_fast do
        Helper.puts("Job is skipped")
        args ++ ["--skip-tags", "job"]
      else
        args
      end

    Ext.Shell.exec(System.find_executable("ansible-playbook"), args, [{:line, 4096}])

    Ext.Commands.SendToSlack.call(
      Helper.settings()[:slack_token], Helper.settings()[:slack_channel],
      ":rocket: :rocket: :rocket: UAT => arcade => build v.develop-500fa8a =>  DELIVERED :tada: :tada: :tada:"
    )
  end
end
