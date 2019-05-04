defmodule Mix.Commands.Deploy.FindOrCreateBuild do
  alias Mix.Helper

  def call(%{tag: tag} = context) do
    repository = Helper.lookup_image_repository()
    token = get_docker_hub_token()
    Helper.puts("Check if build exist #{Mix.Project.config()[:app]}. Repository=#{repository} ImageTag=#{tag}")

    # curl --silent -f -lSL https://hub.docker.com/v2/repositories/planetgr/arcade/tags/dev-e18c9da-23Apr
    args = [
      "pull",
      "--silent",
      "-f",
      "-lSL",
      "-H",
      "Authorization: JWT #{token}",
      "https://hub.docker.com/v2/repositories/#{repository}/tags/#{tag}"
    ]

    {_, status} = System.cmd(System.find_executable("curl"), args)

    if status == 0 do
      Helper.puts("Exist ImageTag=#{tag}")
    else
      Mix.Tasks.Ext.Build.run([tag])
    end

    context
  end

  def get_docker_hub_token() do
    # curl -s -H "Content-Type: application/json" -X POST -d '{"username": "'${UNAME}'", "password": "'${UPASS}'"}' https://hub.docker.com/v2/users/login/
    args = [
      "-s",
      "-H",
      "Content-Type: application/json",
      "-X",
      "POST",
      "-d",
      "{\"username\": \"#{Helper.lookup_docker_hub_user()}\", \"password\": \"#{Helper.lookup_docker_hub_pass()}\"}",
      "https://hub.docker.com/v2/users/login/"
    ]

    {message, status} = System.cmd(System.find_executable("curl"), args)
    case System.cmd(System.find_executable("curl"), args) do
      {message, 0} -> Jason.decode!(message)["token"]
      _ -> ""
    end
  end
end
