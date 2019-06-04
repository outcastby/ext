defmodule Ext.Oauth.SignUp do
  require IEx

  def call(%{payload: %{email: email}} = args, uid, %{form: form} = params) do
    form = form.changeset(%{email: email})

    cond do
      form.valid? ->
        call(args, uid, Map.delete(params, :form))

      true ->
        {:error, form}
    end
  end

  def call(%{payload: %{email: email}, provider: provider}, uid, %{repo: repo, schemas: %{user: user_schema}} = params) do
    user = repo.save!(user_schema.__struct__, %{email: email})
    create_authorizations(user, provider, uid, params)
    {:ok, user}
  end

  def call(
        %{payload: payload, provider: provider},
        uid,
        %{
          repo: repo,
          schemas: %{user: user_schema}
        } = params
      ) do
    case Ext.Oauth.GetUserDetails.call(provider, payload) do
      %{email: email} ->
        user = repo.get_or_insert!(user_schema, %{email: email})

        create_authorizations(user, provider, uid, params)

        {:ok, user}

      _ ->
        {:error, :email_not_found}
    end
  end

  defp create_authorizations(user, provider, uid, %{repo: repo, schemas: %{user: user_schema, auth: auth_schema}}) do
    user
    |> Ecto.build_assoc(Ext.Ecto.Schema.get_schema_assoc(user_schema, auth_schema), %{provider: provider, uid: uid})
    |> repo.insert!()
  end
end
