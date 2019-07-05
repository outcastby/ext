defmodule ExtTest do
  use ExUnit.Case
  doctest Ext.Utils.DateTime
  doctest Ext.Gql.Resolvers.Proxy
  doctest Ext.Gql.Resolvers.CamelCase
  doctest Ext.Utils.Base
  doctest Ext.Utils.Enum
  doctest Ext.Utils.Forms
  doctest Ext.Utils.List
  doctest Ext.Utils.Repo
  doctest Ext.Gql.Resolvers.Base
end
