defmodule Ext.Facebook.GetAppAccessToken do
  require Logger
  require IEx

  def call do
    request = %Ext.Sdk.Request{
      payload: %{
        client_id: Application.get_env(Mix.Project.config()[:app], :ext)[:facebook_client_id],
        client_secret: Application.get_env(Mix.Project.config()[:app], :ext)[:facebook_client_secret],
        grant_type: "client_credentials"
      }
    }

    case Ext.Sdk.Facebook.Client.app_token(request) do
      {:ok, %{"access_token" => access_token}} ->
        access_token

      {:error, response} ->
        Logger.error("Error get app_token for facebook, message - #{inspect(response)}")
        nil
    end
  end
end
