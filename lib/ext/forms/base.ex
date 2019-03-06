defmodule Ext.Forms.Base do
  @doc false

  defmacro schema(name, fields) do
    quote do
      schema unquote(name) do
        unquote(fields)
        field :context, :map, default: %{}
      end
    end
  end

  defmacro __using__(_) do
    quote do
      require IEx
      require Logger
      use Ecto.Schema
      import Ecto.Changeset

      def with_context(form, params) do
        old_params = get_in(form.changes, [:context])

        cond do
          old_params -> cast(form, %{context: Map.merge(old_params, params)}, [:context])
          true -> cast(form, %{context: params}, [:context])
        end
      end

      def build_args(params, context) do
        form = cast(__struct__(), params, Map.keys(__struct__()) -- [:__meta__, :__struct__, :context])
        __MODULE__.with_context(form, context)
      end
    end
  end
end
