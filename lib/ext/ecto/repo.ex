defmodule Ext.Ecto.Repo do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import Ecto.Query

      defoverridable exists?: 2, get_by: 3, get_by!: 3

      def exists?(queryable, clauses, opts \\ []) do
        Ecto.Repo.Queryable.exists?(__MODULE__, Ecto.Query.where(queryable, [], ^Enum.to_list(clauses)), opts)
      end

      def get_by(queryable, clauses, opts) do
        Ecto.Repo.Queryable.get_by(__MODULE__, queryable, Ext.Utils.Base.atomize_keys(clauses), opts)
      end

      def get_by!(queryable, clauses, opts) do
        Ecto.Repo.Queryable.get_by!(__MODULE__, queryable, Ext.Utils.Base.atomize_keys(clauses), opts)
      end

      def first(query) do
        query |> Ecto.Query.limit(1) |> one()
      end

      def where(query, params) do
        Enum.reduce(Ext.Utils.Base.atomize_keys(params), query, &compose_query/2)
      end

      defp compose_query(params, query, type \\ "=")

      defp compose_query({key, value}, query, type) when is_map(value) do
        compose_query({key, {value[:type] || value["type"], value["value"] || value[:value]}}, query, type)
      end

      defp compose_query({key, value}, query, _type) when is_tuple(value) do
        case value do
          {">", value} -> query |> where([entity], field(entity, ^key) > ^value)
          {">=", value} -> query |> where([entity], field(entity, ^key) >= ^value)
          {"<", value} -> query |> where([entity], field(entity, ^key) < ^value)
          {"<=", value} -> query |> where([entity], field(entity, ^key) <= ^value)
          {"=", value} -> compose_query({key, value}, query, "=")
          {"!=", value} -> compose_query({key, value}, query, "!=")
        end
      end

      defp compose_query({key, [head | tail] = value}, query, type)
           when is_list(value) and head in [">", ">=", "<", "<=", "=", "!="] do
        compose_query({key, List.to_tuple(value)}, query, type)
      end

      defp compose_query({key, value}, query, type) when is_list(value) do
        case type do
          "=" -> query |> where([entity], field(entity, ^key) in ^value)
          "!=" -> query |> where([entity], field(entity, ^key) not in ^value)
        end
      end

      defp compose_query({key, nil}, query, type) do
        case type do
          "=" -> query |> where([entity], is_nil(field(entity, ^key)))
          "!=" -> query |> where([entity], not is_nil(field(entity, ^key)))
        end
      end

      defp compose_query({key, value}, query, type) do
        case type do
          "=" -> query |> where([entity], ^[{key, value}])
          "!=" -> query |> where([entity], field(entity, ^key) != ^value)
        end
      end

      def batch_insert(schema_or_source, entries, batch, opts \\ []) do
        Enum.each(
          Enum.chunk_every(entries, batch),
          &Ecto.Repo.Schema.insert_all(__MODULE__, schema_or_source, &1, opts)
        )
      end

      def order_by(query, fields), do: from(en in query, order_by: ^fields)

      def cache_key(%module{id: id, updated_at: updated_at}) do
        [Ext.Utils.Base.to_str(module), id, updated_at |> DateTime.to_string()] |> Enum.join("/")
      end

      def cache_key(query) do
        from(r in query, select: max(r.updated_at)) |> __MODULE__.one()
      end

      def transaction_repeateble_read! do
        if Mix.env() != :test do
          __MODULE__.query!("set transaction isolation level repeatable read;")
        end
      end

      def reload(%module{id: id}) do
        get(module, id)
      end
    end
  end
end
