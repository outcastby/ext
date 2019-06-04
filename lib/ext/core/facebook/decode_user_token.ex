defmodule Ext.Facebook.DecodeUserToken do
  require Logger
  require IEx

  def call(user_token) do
    app_token = Ext.Facebook.GetAppAccessToken.call()

    request = %Ext.Sdk.Request{
      payload: %{
        input_token: user_token,
        access_token: app_token
      }
    }

    case Ext.Sdk.Facebook.Client.debug_user_token(request) do
      {:ok, %{"data" => data}} ->
        data

      {:error, response} ->
        Logger.error("Error when try to decode user access token, message - #{inspect(response)}")
        nil
    end
  end
end
