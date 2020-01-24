defmodule Ext.Logger.Json do
  import Ext.Utils.Map

  def format(level, message, timestamp, metadata) do
    try do
      time =
        case Timex.format(timestamp, "{ISO:Extended:Z}") do
          {:ok, time_str} -> time_str
          _ -> Timex.format!(Timex.now(), "{ISO:Extended:Z}")
        end

      log_data = %{"msg" => normalize_msg(message), "level" => level, "ts" => time} ||| Map.new(metadata)
      "#{Jason.encode!(log_data)}\n"
    rescue
      _ -> "#{timestamp} #{metadata[level]} #{level} #{normalize_msg(message)}\n"
    end
  end

  defp normalize_msg(msg) when is_binary(msg), do: msg
  defp normalize_msg(msg), do: inspect(msg)
end
