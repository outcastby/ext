defmodule Ext.Gql.Resolvers.CamelCase do
  require IEx

  def call(field_name) do
    fn _args, %{source: source} ->
      {:ok, camel_case(Map.get(source, field_name))}
    end
  end

  def camel_case(value) when is_binary(value) or is_atom(value), do: ProperCase.camel_case(value)
  def camel_case(value) when is_map(value), do: ProperCase.to_camel_case(value)
  def camel_case(value), do: value
end
