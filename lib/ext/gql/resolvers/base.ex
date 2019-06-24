defmodule Ext.Gql.Resolvers.Base do
  @moduledoc false
  require IEx
  require Ecto.Query
  import Ext.Utils.Map

  defmacro __using__(_) do
    quote do
      use JaSerializer
      require IEx

      def send_errors(form, code \\ 400, message \\ "Validation Error") do
        Ext.Gql.Resolvers.Base.send_errors(form, code, message)
      end
    end
  end

  def send_errors(form, code \\ 400, message \\ "Validation Error")

  def send_errors(%Ecto.Changeset{} = form, code, message) do
    {:error, message: message, code: code, details: ProperCase.to_camel_case(Ext.Utils.Forms.error(form))}
  end

  def send_errors({message, details}, code, _),
    do: {:error, message: message, details: ProperCase.to_camel_case(details), code: code}

  def send_errors(message, code, _), do: {:error, message: message, code: code}

  def all(schema, preload \\ [], repo \\ nil) do
    {_, repo} = Ext.Utils.Repo.get_config(repo)

    fn args, _ ->
      page_limit = args[:limit]
      offset = args[:offset] || 0
      filter = if args[:filter], do: args[:filter], else: %{}

      order_by =
        if args[:order], do: Ext.Utils.Base.to_keyword_list(args[:order]), else: [desc: :inserted_at, desc: :id]

      try do
        entities =
          schema
          |> repo.where(filter)
          |> repo.order_by(order_by)
          |> Ecto.Query.limit(^page_limit)
          |> Ecto.Query.offset(^offset)
          |> repo.all()
          |> repo.preload(preload)

        {:ok, entities}
      rescue
        e in Ecto.QueryError -> {:error, e.message}
        e in Ecto.Query.CastError -> {:error, e.message}
      end
    end
  end

  def find(schema, preload \\ [], repo \\ nil) do
    {_app_name, repo} = Ext.Utils.Repo.get_config(repo)
    fn %{id: id}, _ -> get(schema, id, preload, repo) end
  end

  def update(args) when is_map(args) do
    {schema, repo, form_module, scope} = parse_args(args)
    update(schema, repo, form_module, scope)
  end

  def update(schema, repo \\ nil, form_module \\ nil, scope \\ %{}) do
    {_, repo} = Ext.Utils.Repo.get_config(repo)

    fn %{id: id, entity: entity_params}, _info ->
      {entity_params, preload_assoc} = build_assoc_data(schema, repo, entity_params)

      case get(schema, id, preload_assoc, repo, scope) do
        {:ok, entity} ->
          case valid?(form_module, Map.merge(entity_params, %{id: id})) do
            true -> entity |> schema.changeset(entity_params) |> repo.update()
            form -> send_errors(form)
          end

        {:error, message} ->
          {:error, message}
      end
    end
  end

  def create(args) when is_map(args) do
    {schema, repo, form_module, scope} = parse_args(args)
    create(schema, repo, form_module, scope)
  end

  def create(schema, repo \\ nil, form_module \\ nil, scope \\ %{}) do
    {_, repo} = Ext.Utils.Repo.get_config(repo)

    fn %{entity: entity_params}, _info ->
      {entity_params, _} = build_assoc_data(schema, repo, entity_params ||| scope)

      case valid?(form_module, entity_params) do
        true ->
          entity = struct(schema) |> schema.changeset(entity_params) |> repo.insert!()
          {:ok, entity |> repo.reload()}

        form ->
          send_errors(form)
      end
    end
  end

  def delete(schema, repo \\ nil, scope \\ %{}) do
    {_, repo} = Ext.Utils.Repo.get_config(repo)

    fn %{id: id}, _info ->
      case get(schema, id, [], repo, scope) do
        {:ok, entity} -> repo.delete(entity)
        {:error, message} -> {:error, message}
      end
    end
  end

  def get(schema, id, preload \\ [], repo \\ nil, scope \\ %{}) do
    {_, repo} = Ext.Utils.Repo.get_config(repo)

    case schema |> repo.where(scope) |> repo.get(id) |> repo.preload(preload) do
      nil -> {:error, "#{inspect(schema)} id #{id} not found"}
      entity -> {:ok, entity}
    end
  end

  defp parse_args(args), do: {args[:schema], args[:repo], args[:form], args[:scope] || %{}}

  def valid?(form_module, entity_params) do
    cond do
      form_module ->
        form = form_module.changeset(entity_params)
        if form.valid?, do: true, else: form

      true ->
        true
    end
  end

  def build_assoc_data(schema, repo, entity_params) do
    Enum.reduce(entity_params, {entity_params, []}, fn {k, v}, {entity_params, preload_assoc} ->
      assoc_schema = get_assoc_schema(schema, k)

      if is_list(v) && assoc_schema do
        assoc_entities = assoc_schema |> repo.where(id: v) |> repo.all()
        {Map.merge(entity_params, %{k => assoc_entities}), preload_assoc ++ [k]}
      else
        {entity_params, preload_assoc}
      end
    end)
  end

  def get_assoc_schema(schema, key) do
    case schema.__changeset__[key] do
      {:assoc, %{queryable: queryable}} -> queryable
      _ -> nil
    end
  end

  def total(%{repo: repo, schema: schema} = args, _) do
    filter = if args[:filter], do: args[:filter], else: %{}
    schema = String.to_atom("Elixir.#{schema}")
    repo = String.to_atom("Elixir.#{repo}")

    {:ok, schema |> repo.where(filter) |> repo.aggregate(:count, :id)}
  end
end
