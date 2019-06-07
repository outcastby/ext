defmodule Ext.Oauth.SignUp do
  import Ext.Utils.Map
  require IEx

  def call(%{payload: %{entity: entity}} = args, uid, %{form: form} = params) do
    form = form.changeset(entity)

    cond do
      form.valid? ->
        perform_sign_up(args, uid, params)

      true ->
        {:error, form}
    end
  end

  def call(args, uid, params) do
    perform_sign_up(args, uid, params)
  end

  defp perform_sign_up(
         %{payload: payload, provider: provider},
         uid,
         %{repo: repo, schemas: %{user: user_schema}, required_fields: required_fields} = params
       ) do
    user_details = Ext.Oauth.GetUserDetails.call(provider, payload)
    entity = payload[:entity] || %{}

    missing_fields = Enum.into(required_fields -- Map.keys(user_details ||| entity), %{}, &{&1, ["can't be blank"]})

    if Blankable.blank?(missing_fields) do
      user =
        if user_details[:email],
           do: repo.get_or_insert!(user_schema, %{email: user_details.email}, user_details),
           else: repo.save!(user_schema.__struct__, user_details ||| entity)

      create_authorizations(user, provider, uid, params)

      {:ok, user}
    else
      {:error, {:authorization_not_complete, missing_fields}}
    end
  end

  defp create_authorizations(user, provider, uid, %{repo: repo, schemas: %{user: user_schema, auth: auth_schema}}) do
    user
    |> Ecto.build_assoc(Ext.Ecto.Schema.get_schema_assoc(user_schema, auth_schema), %{provider: provider, uid: uid})
    |> repo.insert!()
  end
end
