defmodule Ext.Ecto.Repo do
  @moduledoc false

  defmacro __using__(_) do
    quote do

      import Ecto.Query

      defoverridable exists?: 2

      def exists?(queryable, clauses, opts \\ []) do
        Ecto.Repo.Queryable.exists?(__MODULE__, Ecto.Query.where(queryable, [], ^Enum.to_list(clauses)), opts)
      end

      def first(query) do
        query |> Ecto.Query.limit(1) |> one()
      end

      def where(query, params) do
        Enum.reduce(params, query, &compose_query/2)
      end

      defp compose_query({key, value}, query) when is_list(value) do
        query |> where([entity], field(entity, ^key) in ^value)
      end

      defp compose_query({key, nil}, query) do
        query |> where([entity], is_nil(field(entity, ^key)))
      end

      defp compose_query({key, value}, query) do
        query |> where([entity], ^[{key, value}])
      end

      def batch_insert(schema_or_source, entries, batch, opts \\ []) do
        Enum.each(Enum.chunk_every(entries, batch), &Ecto.Repo.Schema.insert_all(__MODULE__, schema_or_source, &1, opts))
      end

      def order_by(query, fields), do: from(en in query, order_by: ^fields)

      def cache_key(%module{id: id, updated_at: updated_at}) do
        [Ext.Utils.Base.to_str(module), id, updated_at |> DateTime.to_string()] |> Enum.join("/")
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
