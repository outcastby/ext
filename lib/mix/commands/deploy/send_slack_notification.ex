defmodule Mix.Commands.Deploy.SendSlackNotification do
  alias Mix.Helper
  require IEx

  def messages(env_name, tag) do
    %{
      before:
        ":warning: :warning: :warning: #{env_name} => #{Mix.Project.config()[:app]} => #{tag} => START DEPLOY :no_pedestrians:",
      after:
        ":rocket: :rocket: :rocket: #{env_name} => #{Mix.Project.config()[:app]} => #{tag} => DELIVERED :muscle_left_anim: :deda: :muscle_right_anim:"
    }
  end

  def call(%{tag: tag, env_name: env_name} = context, type) do
    message = messages(env_name, tag)[type]
    Ext.Commands.SendToSlack.call(Helper.settings()[:slack_token], Helper.settings()[:slack_channel], message)
    context
  end
end
