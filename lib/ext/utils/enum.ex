defmodule Ext.Utils.Enum do
  require IEx

  @doc ~S"""
  Calculates a sum from the elements by callback

  ## Examples
    iex> Ext.Utils.Enum.sum_by([1, 2, 3], &(&1 - 1))
    3

    iex> Ext.Utils.Enum.sum_by(%{one: 1, two: 2, three: 3}, fn {_key, value} -> value + 1 end)
    9

    iex> Ext.Utils.Enum.sum_by([%{name: "one", value: 1}, %{name: "two", value: 2}], &(&1.value))
    3
  """

  def sum_by(enum, callback) do
    Enum.reduce(enum, 0, fn item, sum ->
      sum + callback.(item)
    end)
  end
end
