defmodule Ext.Oauth.Google.GetUserDetails do
  def call(%{id_token: token}) do
    {:ok, google_user} = Joken.peek_claims(token)
    %{email: google_user["email"], name: google_user["name"], id: google_user["sub"]}
  end
end
