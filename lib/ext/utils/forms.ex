defmodule Ext.Utils.Forms do
  @moduledoc false
  require Logger
  import Ecto.Changeset

  def error(changeset) do
    traverse_errors(changeset, fn {msg, opts} ->
      Enum.reduce(opts, msg, fn {key, value}, acc ->
        String.replace(acc, "%{#{key}}", to_string(value))
      end)
    end)
  end
end
