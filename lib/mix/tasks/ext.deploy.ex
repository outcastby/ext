defmodule Mix.Tasks.ExtDeploy do
  use Mix.Task
  alias Mix.Helper

  def run([env_name] = args) when length(args) == 1 do
    run([env_name, Helper.lookup_image_tag()])
  end

  def run([env_name, image_tag]) do
    Helper.puts("Deploy service arcade, #{env_name}, #{image_tag}")

    Ext.Shell.exec(
      System.find_executable("ansible-playbook"),
      ["-i", "inventory", "playbook.yml", "--extra-vars", "env_name=#{env_name} image_tag=#{image_tag}"],
      [{:line, 4096}]
    )
  end
end
