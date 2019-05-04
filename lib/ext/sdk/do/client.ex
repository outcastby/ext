defmodule Ext.Sdk.Do.Client do
  use Ext.Sdk.BaseClient, endpoints: Map.keys(Ext.Sdk.Do.Config.data().endpoints)
  require IEx
  require Logger

  def prepare_headers(headers) do
    if !Ext.Sdk.Do.Config.data().access_token do
      raise "ENV DO_ACCESS_TOKEN should be filled"
    end

    [Authorization: "Bearer " <> Ext.Sdk.Do.Config.data().access_token] ++ headers
  end
end
