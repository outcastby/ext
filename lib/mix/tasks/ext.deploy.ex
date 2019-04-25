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
    HTTPoison.start()
    Helper.puts("Deploy service #{Mix.Project.config()[:app]}. Environment=#{env_name}. Image=#{image_tag}")

    find_or_create_build(image_tag)

    args = ["-i", "inventory", "playbook.yml", "--extra-vars", "env_name=#{env_name} image_tag=#{image_tag}"]

    args =
      if is_fast do
        Helper.puts("Job is skipped")
        args ++ ["--skip-tags", "job"]
      else
        args
      end

    slack_notification(
      ":warning: :warning: :warning: #{env_name} => #{Mix.Project.config()[:app]} => #{image_tag} =>  START DEPLOY :no_pedestrians:"
    )

    Ext.Shell.exec(System.find_executable("ansible-playbook"), args, [{:line, 4096}])

    slack_notification(
      ":rocket: :rocket: :rocket: #{env_name} => #{Mix.Project.config()[:app]} => #{image_tag} =>  DELIVERED :muscle_left_anim: :deda: :muscle_right_anim:"
    )
  end

  defp slack_notification(message),
    do: Ext.Commands.SendToSlack.call(Helper.settings()[:slack_token], Helper.settings()[:slack_channel], message)

  def find_or_create_build(image_tag) do
    repository = Helper.lookup_image_repository()
    Helper.puts("Check if build exist #{Mix.Project.config()[:app]}. Repository=#{repository} ImageTag=#{image_tag}")

    # curl --silent -f -lSL https://hub.docker.com/v2/repositories/planetgr/arcade/tags/dev-e18c9da-23Apr
    {_, status} =
      System.cmd(System.find_executable("curl"), [
        "pull",
        "--silent",
        "-f",
        "-lSL",
        "https://hub.docker.com/v2/repositories/#{repository}/tags/#{image_tag}"
      ])

    if status == 0 do
      Helper.puts("Exist ImageTag=#{image_tag}")
    else
      Mix.Tasks.Ext.Build.run([image_tag])
    end
  end
end
