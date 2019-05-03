defmodule Mix.Commands.Deploy.SendSlackNotification do
  alias Mix.Helper

  def call(%{tag: tag, env_name: env_name} = context, :before),
    do:
      do_send(
        context,
        ":warning: :warning: :warning: #{env_name} => #{Mix.Project.config()[:app]} => #{tag} =>  START DEPLOY :no_pedestrians:"
      )

  def call(%{tag: tag, env_name: env_name} = context, :after),
    do:
      do_send(
        ":rocket: :rocket: :rocket: #{env_name} => #{Mix.Project.config()[:app]} => #{tag} =>  DELIVERED :muscle_left_anim: :deda: :muscle_right_anim:"
      )

  def do_send(context, message) do
    Ext.Commands.SendToSlack.call(Helper.settings()[:slack_token], Helper.settings()[:slack_channel], message)
    context
  end
end
