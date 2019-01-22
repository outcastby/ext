defmodule Ext.Gql.Resolvers.Base do
  @moduledoc false
  require IEx
  require Ecto.Query

  defmacro __using__(_) do
    quote do
      use JaSerializer
      require IEx

      def send_errors(form, code \\ 400, message \\ "Validation Error") do
        {:error, message: message, code: code, details: Ext.Utils.Forms.error(form)}
      end
    end
  end

  def all(schema, preload \\ [], repo \\ nil) do
    {app_name, repo} = get_config(repo)

    fn args, _ ->
      page_limit = args[:limit] || Application.get_env(app_name, :page_limit) || 20
      offset = args[:offset] || 0

      {:ok,
       schema
       |> repo.where(Map.drop(args, [:limit, :offset]))
       |> repo.order_by(desc: :id)
       |> Ecto.Query.limit(^page_limit)
       |> Ecto.Query.offset(^offset)
       |> repo.all()
       |> repo.preload(preload)}
    end
  end

  def find(schema, repo \\ nil) do
    {_app_name, repo} = get_config(repo)
    fn %{id: id}, _ -> get(schema, id, repo) end
  end

  def update(schema, repo \\ nil) do
    {_, repo} = get_config(repo)

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

          entity |> schema.changeset(entity_params) |> repo.update()

        {:error, message} ->
          {:error, message}
      end
    end
  end

  def create(schema, repo \\ nil) do
    {_, repo} = get_config(repo)

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

      entity = struct(schema) |> schema.changeset(entity_params) |> repo.insert!()
      {:ok, entity |> repo.reload()}
    end
  end

  def delete(schema, repo \\ nil) do
    {_, repo} = get_config(repo)

    fn %{id: id}, _info ->
      case get(schema, id, repo) do
        {:ok, entity} -> repo.delete(entity)
        {:error, message} -> {:error, message}
      end
    end
  end

  def get(schema, id, repo \\ nil) do
    {_, repo} = get_config(repo)

    case schema |> repo.get(id) do
      nil -> {:error, "#{inspect(schema)} id #{id} not found"}
      entity -> {:ok, entity}
    end
  end

  defp get_config(repo \\ nil) do
    app_name = Mix.Project.config()[:app]
    repo = if repo, do: repo, else: Application.get_env(app_name, :ecto_repos) |> List.first()
    {app_name, repo}
  end
end
