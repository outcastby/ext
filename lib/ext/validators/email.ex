defmodule Ext.Validators.Email do
  import Ecto.Changeset
  require IEx

  def call(form, args) do
    {field, message} = parse_args(args)

    case Regex.run(~r/^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,4}$/, Map.get(form.changes, field)) do
      nil -> form |> add_error(field, message)
      _ -> form
    end
  end

  defp parse_args(args), do: {args[:field], args[:message] || "invalid_email"}
end
