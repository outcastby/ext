defmodule Mix.Tasks.ExtDeploy do
  use Mix.Task
  require IEx
  require Logger
  alias Mix.Utils

  def run([env_name] = args) when length(args) == 1 do
    run([env_name, Utils.lookup_image_tag()])
  end

  def run([env_name, image_tag]) do
    Utils.puts("Deploy service arcade, #{env_name}, #{image_tag}")

    Shell.exec(
      System.find_executable("ansible-playbook"),
      ["-i", "inventory", "playbook.yml", "--extra-vars", "env_name=#{env_name} image_tag=#{image_tag}"],
      [{:line, 4096}]
    )
  end
end
