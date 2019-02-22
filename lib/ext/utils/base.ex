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
  def to_atom(value) when is_list(value), do: Enum.map(value, &__MODULE__.to_atom(&1))
  def to_atom(value), do: AtomicMap.convert(value, safe: false)

  def atomize_keys(map) do
    for {key, val} <- map, into: %{} do
      cond do
        is_atom(key) -> {key, val}
        true -> {String.to_atom(key), val}
      end
    end
  end

  def stringify_keys(nil), do: nil

  def stringify_keys(map = %{}) do
    map
    |> Enum.map(fn {k, v} ->
      cond do
        is_atom(k) -> {Atom.to_string(k), stringify_keys(v)}
        is_binary(k) -> {k, stringify_keys(v)}
      end
    end)
    |> Enum.into(%{})
  end

  def stringify_keys([head | rest]), do: [stringify_keys(head) | stringify_keys(rest)]
  def stringify_keys(not_a_map), do: not_a_map

  def snake_keys(map), do: ProperCase.to_snake_case(map)

  def to_str(value) when is_atom(value), do: Atom.to_string(value)
  def to_str(value) when is_float(value), do: :erlang.float_to_binary(value, [:compact, {:decimals, 0}])
  def to_str(value), do: inspect(value)

  def to_negative(value), do: -1 * value

  def to_bool("true"), do: true
  def to_bool("false"), do: false
  def to_bool(nil), do: false
  def to_bool(_any_value), do: true

  def get_in(object, list) do
    [source_column | path] = list

    new_value =
      if is_nil(Map.get(object, source_column)),
        do: Map.get(object, to_str(source_column)),
        else: Map.get(object, source_column)

    cond do
      new_value == nil -> nil
      length(path) == 0 -> new_value
      true -> __MODULE__.get_in(new_value, path)
    end
  end

  def put_in(object, path, value) when length(path) == 1 do
    key = List.first(path)
    Map.merge(object, %{key => value})
  end

  def put_in(object, path, value) do
    [head | path] = path

    branch =
      case __MODULE__.get_in(object, [head]) do
        nil ->
          object = Kernel.put_in(object, [head], %{})
          __MODULE__.put_in(__MODULE__.get_in(object, [head]), path, value)

        new_object ->
          __MODULE__.put_in(new_object, path, value)
      end

    Map.merge(object, %{head => branch})
  end

  def check_env_variables(env_path \\ ".env.sample") do
    env_content = File.read!(env_path)

    env_array =
      String.split(env_content, "export ", trim: true) |> Enum.map(fn x -> String.replace(x, ~r/=.+\n/, "") end)

    Enum.each(env_array, fn env ->
      unless System.get_env(env), do: Logger.error("Environment variable #{env} does not set")
    end)
  end

  def to_keyword_list(data) do
    Enum.reduce(data, [], fn {key, value}, acc ->  [{to_atom(key), to_atom(value)} | acc] end)
  end
end
