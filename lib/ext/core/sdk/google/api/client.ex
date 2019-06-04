defmodule Ext.Sdk.Google.Api.Client do
  use Ext.Sdk.BaseClient, endpoints: Map.keys(Ext.Sdk.Google.Api.Config.data().endpoints)
  require IEx
  require Logger
end
