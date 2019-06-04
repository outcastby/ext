defmodule Ext.Oauth.GetUserUniqKey do
  def call(%{provider: provider, payload: payload}) do
    module = String.to_atom("Elixir.Ext.Oauth.#{Macro.camelize("#{provider}")}.GetUserUniqKey")
    module.call(payload)
  end
end
