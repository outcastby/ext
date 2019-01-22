defmodule Ext.Utils.Base do
  require Logger

  @moduledoc false
  def to_int(value) do
    case :string.to_integer(value) do
      {:error, _} -> value
      {int, _} -> int
    end
  end

  def to_atom(value) when is_binary(value), do: String.to_atom(value)
  def to_atom(value) when is_nil(value), do: nil
  def to_atom(value), do: AtomicMap.convert(value, safe: false)

  def atomize_keys(map) do
    for {key, val} <- map, into: %{} do
      cond do
        is_atom(key) -> {key, val}
        true -> {String.to_atom(key), val}
      end
    end
  end

  def to_str(value) when is_atom(value), do: Atom.to_string(value)
  def to_str(value) when is_float(value), do: :erlang.float_to_binary(value, [:compact, { :decimals, 0 }])
  def to_str(value), do: inspect(value)

  def to_negative(value), do: -1 * value

  def to_bool("true"), do: true
  def to_bool("false"), do: false
  def to_bool(nil), do: false
  def to_bool(_any_value), do: true

  def get_in(object, list) do
    [source_column | path] = list

    new_value = Map.get(object, source_column) || Map.get(object, to_str(source_column))

    cond do
      new_value == nil -> nil
      length(path) == 0 -> new_value
      true -> __MODULE__.get_in(new_value, path)
    end
  end

  def check_env_variables(env_path \\ ".env.sample") do
    env_content = File.read!(env_path)

    env_array =
      String.split(env_content, "export ", trim: true) |> Enum.map(fn x -> String.replace(x, ~r/=.+\n/, "") end)

    Enum.each(env_array, fn env ->
      unless System.get_env(env), do: Logger.error("Environment variable #{env} does not set")
    end)
  end
end
