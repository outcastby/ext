defmodule Ext.Gql.Resolvers.Base do
  @moduledoc false
  require IEx
  require Ecto.Query

  defmacro __using__(_) do
    quote do
      use JaSerializer
      require IEx

      def send_errors(form, code \\ 400, message \\ "Validation Error") do
        Ext.Gql.Resolvers.Base.send_errors(form, code, message)
      end
    end
  end

  def send_errors(form, code \\ 400, message \\ "Validation Error") do
    {:error, message: message, code: code, details: ProperCase.to_camel_case(Ext.Utils.Forms.error(form))}
  end

  def all(schema, preload \\ [], repo \\ nil) do
    {app_name, repo} = Ext.Utils.Repo.get_config(repo)

    fn args, _ ->
      page_limit = args[:limit] || Application.get_env(app_name, :page_limit) || 20
      offset = args[:offset] || 0
      filter = Jason.decode!(args[:filter] || "{}") |> Ext.Utils.Base.snake_keys()
      try do
        entities =
          schema
          |> repo.where(filter)
          |> repo.order_by(desc: :id)
          |> Ecto.Query.limit(^page_limit)
          |> Ecto.Query.offset(^offset)
          |> repo.all()
          |> repo.preload(preload)

        {:ok, entities}
      rescue
        e in Ecto.QueryError-> {:error, e.message}
        e in Ecto.Query.CastError-> {:error, e.message}
      end
    end
  end

  def find(schema, repo \\ nil) do
    {_app_name, repo} = Ext.Utils.Repo.get_config(repo)
    fn %{id: id}, _ -> get(schema, id, repo) end
  end

  def update(args) when is_map(args) do
    {schema, repo, form_module} = parse_args(args)
    update(schema, repo, form_module)
  end

  def update(schema, repo \\ nil, form_module \\ nil) do
    {_, repo} = Ext.Utils.Repo.get_config(repo)

    fn %{id: id, entity: entity_params}, _info ->
      case get(schema, id, repo) do
        {:ok, entity} ->
          entity_params =
            if entity_params[:extra] do
              extra = Map.merge(Ext.Utils.Base.to_atom(entity.extra), entity_params.extra)
              Map.merge(entity_params, %{extra: extra})
            else
              entity_params
            end

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
    {schema, repo, form_module} = parse_args(args)
    create(schema, repo, form_module)
  end

  def create(schema, repo \\ nil, form_module \\ nil) do
    {_, repo} = Ext.Utils.Repo.get_config(repo)

    fn %{entity: entity_params}, _info ->
      entity_params =
        if :erlang.function_exported(schema, :default_state, 0) do
          default_state = schema.default_state

          if default_state[:extra] do
            extra = Map.merge(entity_params.extra, default_state.extra)
            Map.merge(entity_params, default_state) |> Map.merge(%{extra: extra})
          else
            Map.merge(entity_params, default_state)
          end
        else
          entity_params
        end

      case valid?(form_module, entity_params) do
        true ->
          entity = struct(schema) |> schema.changeset(entity_params) |> repo.insert!()
          {:ok, entity |> repo.reload()}
        form ->
          send_errors(form)
      end
    end
  end

  def delete(schema, repo \\ nil) do
    {_, repo} = Ext.Utils.Repo.get_config(repo)

    fn %{id: id}, _info ->
      case get(schema, id, repo) do
        {:ok, entity} -> repo.delete(entity)
        {:error, message} -> {:error, message}
      end
    end
  end

  def get(schema, id, repo \\ nil) do
    {_, repo} = Ext.Utils.Repo.get_config(repo)

    case schema |> repo.get(id) do
      nil -> {:error, "#{inspect(schema)} id #{id} not found"}
      entity -> {:ok, entity}
    end
  end

  defp parse_args(args), do: {args[:schema], args[:repo], args[:form]}

  def valid?(form_module, entity_params) do
    cond do
      form_module ->
        form = form_module.changeset(entity_params)
        if form.valid?, do: true, else: form
      true ->
        true
    end
  end
end
