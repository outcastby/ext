defmodule Ext.Sdk.Facebook.Client do
  use Ext.Sdk.BaseClient, endpoints: Map.keys(Ext.Sdk.Facebook.Config.data().endpoints)
  require IEx
  require Logger
end
