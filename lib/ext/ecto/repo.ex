defmodule Ext.Ecto.Repo do
  @moduledoc false

  defmacro __using__(_) do
    quote do
      import Ecto.Query
      import Ext.Utils.Map

      defoverridable exists?: 2, get_by: 3, get_by!: 3

      def exists?(queryable, clauses, opts \\ []) do
        Ecto.Repo.Queryable.exists?(__MODULE__, Ecto.Query.where(queryable, [], ^Enum.to_list(clauses)), opts)
      end

      def get_by(queryable, clauses, opts) do
        Ecto.Repo.Queryable.get_by(__MODULE__, queryable, Ext.Utils.Base.to_atom(clauses), opts)
      end

      def get_by!(queryable, clauses, opts) do
        Ecto.Repo.Queryable.get_by!(__MODULE__, queryable, Ext.Utils.Base.to_atom(clauses), opts)
      end

      def first(query) do
        query |> Ecto.Query.limit(1) |> one()
      end

      def where(query, {:or, conditions}) when is_list(conditions),
        do: Ecto.Query.where(query, ^build_or_dynamic(conditions, query))

      def build_or_dynamic(conditions, query) do
        Enum.reduce(conditions, nil, fn params, dynamic ->
          if dynamic,
            do: Ecto.Query.dynamic([e], ^build_conditions(params, query) or ^dynamic),
            else: Ecto.Query.dynamic([e], ^build_conditions(params, query))
        end)
      end

      def where(query, params), do: Ecto.Query.where(query, ^build_conditions(params, query))

      def build_conditions(params, query) do
        Enum.reduce(
          Ext.Utils.Base.to_atom(params),
          nil,
          &Ext.Ecto.ComposeQuery.call(&1, &2, %{
            main_query: query,
            type: "=",
            table_module: Ext.Ecto.GetCondition.Table0
          })
        ) || true
      end

      def batch_insert(schema_or_source, entries, batch \\ 5_000, opts \\ []) do
        Enum.each(
          Enum.chunk_every(entries, batch),
          &Ecto.Repo.Schema.insert_all(:repo, __MODULE__, schema_or_source, &1, opts)
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

      def save(struct, data), do: save(struct, data, nil)
      def save!(struct, data), do: save(struct, data, "!")

      def save(struct, data, bang),
        do: apply(__MODULE__, String.to_atom("insert_or_update#{bang}"), [struct.__struct__.changeset(struct, data)])

      def get_or_insert(schema, query, extra_params \\ %{}), do: get_or_insert(schema, query, extra_params, nil)
      def get_or_insert!(schema, query, extra_params \\ %{}), do: get_or_insert(schema, query, extra_params, "!")

      defp get_or_insert(schema, query, extra_params, bang) do
        case schema |> __MODULE__.get_by(query) do
          nil ->
            apply(__MODULE__, String.to_atom("save#{bang}"), [schema.__struct__, query ||| extra_params])

          entity ->
            case bang do
              "!" -> entity
              _ -> {:ok, entity}
            end
        end
      end
    end
  end
end
