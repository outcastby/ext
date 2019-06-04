defmodule Ext.Oauth.Facebook.GetUserDetails do
  require Logger
  require IEx

  def call(%{access_token: access_token}) do
    request = %Ext.Sdk.Request{
      payload: %{fields: "id,name,email", access_token: access_token}
    }

    case Ext.Sdk.Facebook.Client.me(request) do
      {:ok, response} ->
        response |> Ext.Utils.Base.to_atom() |> Map.take([:email, :name, :id])

      {:error, response} ->
        Logger.error("Error get info about player for facebook, message - #{inspect(response)}")
        nil
    end
  end
end
