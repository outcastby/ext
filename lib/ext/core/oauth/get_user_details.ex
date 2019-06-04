defmodule Ext.Oauth.GetUserDetails do
  def call(provider, auth_data) do
    module = String.to_atom("Elixir.Ext.Oauth.#{Macro.camelize("#{provider}")}.GetUserDetails")
    module.call(auth_data)
  end
end
