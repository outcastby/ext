defmodule Ext.Gql.Resolvers.Oauth do
  use Ext.Gql.Resolvers.Base

  def authorize(params) do
    fn args, _ ->
      case Ext.Oauth.Authorize.call(args, params) do
        {:ok, user} -> {:ok, user}
        {:error, data} -> send_errors(data)
      end
    end
  end
end
