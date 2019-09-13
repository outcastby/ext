defmodule Ext.Config do
  def get(path, default_value \\ nil)

  def get(path, default_value) when is_atom(path),
    do: Application.get_env(Mix.Project.config()[:app], path, default_value || [])

  def get(path, default_value) do
    [head | tail] = path
    head |> get() |> get_in_object(tail) || default_value
  end

  defp get_in_object(map, []), do: map
  defp get_in_object(map, path), do: get_in(map, path)
end
