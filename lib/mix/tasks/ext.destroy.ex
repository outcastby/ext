defmodule Mix.Tasks.Ext.Destroy do
  use Mix.Task
  alias Mix.Helper

  def run([env_name, image_tag]) do
    HTTPoison.start()
    Helper.puts("Destroy service #{Mix.Project.config()[:app]}. Environment=#{env_name}. Image=#{image_tag}")

    args = [
      "-i",
      "inventory",
      "playbook_destroy.yml",
      "--extra-vars",
      "env_name=#{env_name} image_tag=#{image_tag} version=#{Helper.parse_tag_version(image_tag)}"
    ]

    Ext.Shell.exec(System.find_executable("ansible-playbook"), args, [{:line, 4096}])
  end
end
