defmodule ExtTest do
  use ExUnit.Case
  doctest Ext.Utils.DateTime
  doctest Ext.Gql.Resolvers.Proxy
  doctest Ext.Gql.Resolvers.CamelCase
  doctest Ext.Utils.Base
end
