defmodule Ext.Oauth.GetUserDetails do
  def call(provider, auth_data) do
    module = String.to_atom("Elixir.Ext.Oauth.#{Macro.camelize("#{provider}")}.GetUserDetails")

    module.call(auth_data)
    |> Map.from_struct()
    |> Enum.filter(fn {_, v} -> v != nil end)
    |> Enum.into(%{})
  end
end
