defmodule Ext.Sdk.Test.Client do
  use Ext.Sdk.BaseClient, endpoints: Map.keys(Ext.Sdk.Test.Config.data().endpoints)
end
