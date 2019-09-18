defmodule Ext.Ws.Queue do
  defmacro __using__(opts) do
    quote bind_quoted: [opts: opts] do
      @expired opts[:expired] || 15 * 60

      def clear(user, subscription_name, event_id), do: Ext.Ws.Queue.clear(user, subscription_name, event_id)
      def clear_all(user, subscription_name), do: Ext.Ws.Queue.clear_all(user, subscription_name)
      def send_next(user, subscription_name, caller), do: Ext.Ws.Queue.send_next(user, subscription_name, caller)

      def push(user, subscription_name, event_id, data),
        do: Ext.Ws.Queue.push(user, subscription_name, event_id, data, @expired)
    end
  end

  def clear(user, subscription_name, event_id) do
    Redix.pipeline!(:redix, [
      ["DEL", event_key(user, subscription_name, event_id)],
      ["LREM", key(user, subscription_name), 0, event_id]
    ])
  end

  def clear_all(user, subscription_name) do
    deleted_keys =
      Redix.command!(:redix, ["LRANGE", key(user, subscription_name), "0", "-1"])
      |> Enum.map(&event_key(user, subscription_name, &1))

    Redix.command!(:redix, ["DEL" | deleted_keys ++ [key(user, subscription_name)]])
  end

  def push(user, subscription_name, event_id, data, expired) do
    Redix.pipeline!(:redix, [
      ["SETEX", event_key(user, subscription_name, event_id), expired, Jason.encode!(data)],
      ["RPUSH", key(user, subscription_name), event_id],
      ["EXPIRE", key(user, subscription_name), expired]
    ])

    data
  end

  def send_next(user, subscription_name, caller) do
    if event = first(user, subscription_name),
      do: caller.(user, subscription_name, event |> Jason.decode!() |> Ext.Utils.Base.to_atom())
  end

  defp key(user, subscription_name), do: "user:#{user.id}:#{Inflex.pluralize(subscription_name)}"
  defp event_key(user, subscription_name, event_id), do: "user:#{user.id}:#{subscription_name}:#{event_id}"

  defp first(user, subscription_name) do
    event_id = Redix.command!(:redix, ["LINDEX", key(user, subscription_name), 0])
    if event_id, do: Redix.command!(:redix, ["GET", event_key(user, subscription_name, event_id)])
  end
end
