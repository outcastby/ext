defmodule Ext.Sdk.Slack.Config do
  def data,
    do: %{
      base_url: "https://slack.com/api",
      sdk_name: "Slack",
      access_token: Mix.Helper.settings()[:slack_token],
      endpoints: %{
        send: %{
          type: :post,
          url: "/chat.postMessage?pretty=1"
        }
      }
    }
end
