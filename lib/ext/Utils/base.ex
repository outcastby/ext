defmodule Ext.Utils.Base do
  @moduledoc false
  def to_int(value) do
    case :string.to_integer(value) do
      {:error, _} -> value
      {int, _} -> int
    end
  end

  @doc """
  Convert any type to string
  """
  def to_atom(value), do: AtomicMap.convert(value, safe: false)

  def to_str(value) when is_atom(value), do: Atom.to_string(value)
  def to_str(value) when is_float(value), do: :erlang.float_to_binary(value, [:compact, { :decimals, 0 }])
  def to_str(value), do: inspect(value)

  def to_negative(value), do: -1 * value

  def to_bool("true"), do: true
  def to_bool("false"), do: false
  def to_bool(nil), do: false
  def to_bool(any_value), do: true

  def get_in(object, list) do
    [source_column | path] = list

    new_value = Map.get(object, source_column) || Map.get(object, to_str(source_column))

    cond do
      new_value == nil -> nil
      length(path) == 0 -> new_value
      true -> __MODULE__.get_in(new_value, path)
    end
  end
end
