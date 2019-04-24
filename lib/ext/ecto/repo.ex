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

      def where(query, {:or, conditions}) when is_list(conditions) do
        Enum.reduce(conditions, query, &__MODULE__.or_where(&2, &1))
      end

      def where(query, params), do: Ecto.Query.where(query, ^build_conditions(query, params))
      def or_where(query, params), do: Ecto.Query.or_where(query, ^build_conditions(query, params))

      def build_conditions(query, params) do
        Enum.reduce(Ext.Utils.Base.atomize_keys(params), nil, &Ext.Ecto.ComposeQuery.call(&1, &2, %{type: "="}))
      end

      def batch_insert(schema_or_source, entries, batch \\ 5_000, opts \\ []) do
        Enum.each(
          Enum.chunk_every(entries, batch),
          &Ecto.Repo.Schema.insert_all(__MODULE__, schema_or_source, &1, opts)
        )
      end

      def order_by(query, fields), do: from(en in query, order_by: ^fields)

      def pluck(query, field), do: from(en in query, select: field(en, ^field)) |> __MODULE__.all()

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
