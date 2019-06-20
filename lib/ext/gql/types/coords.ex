defmodule Ext.Gql.Types.Coords do
  use Absinthe.Schema.Notation
  object :coords do
    field :lat, :float
    field :long, :float
  end
end
