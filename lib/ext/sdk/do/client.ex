defmodule Ext.Sdk.Do.Client do
  use Ext.Sdk.BaseClient, endpoints: Map.keys(Ext.Sdk.Do.Config.data().endpoints)
  require IEx
  require Logger

  def prepare_headers(headers),
    do: [Authorization: "Bearer " <> Ext.Sdk.Do.Config.data().access_token] ++ headers
end
