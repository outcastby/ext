defmodule Ext.Utils.Enum do
  require IEx

  def sum_by(enum, callback) do
    Enum.reduce(enum, 0, fn item, sum ->
      sum + callback.(item)
    end)
  end
end
