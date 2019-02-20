defmodule Mix.Tasks.Ext.FetchCert do
  use Mix.Task
  alias Mix.Helper

  def run([env_name]) do
    HTTPoison.start()
    Helper.puts("Fetch do cert for service #{Mix.Project.config()[:app]}. Environment=#{env_name}")
    args = ["-i", "inventory", "playbook.yml", "--extra-vars", "env_name=#{env_name}", "--tags", "fetch"]
    Ext.Shell.exec(System.find_executable("ansible-playbook"), args, [{:line, 4096}])
  end
end
