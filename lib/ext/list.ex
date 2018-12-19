defmodule Ext.List do
  require IEx

  def index_by(list, func) do
    Enum.reduce(list, %{}, &Map.put(&2, func.(&1), &1))
  end
end
