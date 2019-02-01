defmodule Ext.Commands.SendToSlack do

  def call(token, channel, message) do
    args = %{text: message, pretty: 1, token: token, channel: channel} |> URI.encode_query()
    HTTPoison.post("https://slack.com/api/chat.postMessage?#{args}", [])
  end
end
