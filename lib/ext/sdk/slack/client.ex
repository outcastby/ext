defmodule Ext.Sdk.Slack.Client do
  use Ext.Sdk.BaseClient, endpoints: Map.keys(Ext.Sdk.Slack.Config.data().endpoints)
  require IEx

  def prepare_headers(headers) do
    if !Ext.Sdk.Slack.Config.data().access_token do
      raise "add slack_token to app :ext config"
    end

    [Authorization: "Bearer " <> Ext.Sdk.Slack.Config.data().access_token, "Content-Type": "application/json"] ++
      headers
  end
end
