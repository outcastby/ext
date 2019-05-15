defmodule Ext.Ecto.ComposeQuery do
  import Ecto.Query

  @doc """
    iex> where(query, %{position: %{sign: ">", value: 1}})
    WHERE position > 1
  """
  def call({key, value}, query, extra) when is_map(value) do
    call({key, {value[:sign] || value["sign"], value["value"] || value[:value]}}, query, extra)
  end

  @doc """
    iex> where(query, %{position: {"=", 1})
    WHERE position = 1
  """
  def call({key, {"=", value}}, query, _extra), do: call({key, value}, query, %{type: "="})

  @doc """
    iex> where(query, %{position: {"!=", 1})
    WHERE position != 1
  """
  def call({key, {"!=", value}}, query, _extra), do: call({key, value}, query, %{type: "!="})

  def call({key, {sign, value}}, query, _extra) do
    condition =
      case sign do
        ">" ->
          dynamic([entity], field(entity, ^key) > ^value)

        ">=" ->
          dynamic([entity], field(entity, ^key) >= ^value)

        "<" ->
          dynamic([entity], field(entity, ^key) < ^value)

        "<=" ->
          dynamic([entity], field(entity, ^key) <= ^value)

        "~=" ->
          dynamic([entity], like(fragment("lower(?)", field(entity, ^key)), fragment("lower(?)", ^"%#{value}%")))
      end

    dynamic([entity], ^build_dynamic(query, condition))
  end

  @doc """
    iex> where(query, %{position: ["=", 1])
    WHERE position = 1
  """
  def call({key, [sign, value]}, query, extra) when sign in [">", ">=", "<", "<=", "=", "!=", "~="] do
    call({key, {sign, value}}, query, extra)
  end

  def call({key, value}, query, %{type: type}) do
    condition =
      cond do
        is_list(value) && type == "=" -> dynamic([entity], field(entity, ^key) in ^value)
        is_list(value) && type == "!=" -> dynamic([entity], field(entity, ^key) not in ^value)
        is_nil(value) && type == "=" -> dynamic([entity], is_nil(field(entity, ^key)))
        is_nil(value) && type == "!=" -> dynamic([entity], not is_nil(field(entity, ^key)))
        type == "=" -> dynamic([entity], field(entity, ^key) == ^value)
        type == "!=" -> dynamic([entity], field(entity, ^key) != ^value or is_nil(field(entity, ^key)))
      end

    dynamic([entity], ^build_dynamic(query, condition))
  end

  def build_dynamic(nil, condition), do: dynamic([entity], ^condition)
  def build_dynamic(query, condition), do: dynamic([entity], ^query and ^condition)
end
