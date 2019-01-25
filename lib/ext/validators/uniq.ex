defmodule Ext.Validators.Uniq do
  import Ecto.Changeset

  def call(form, args) do
    {schema, repo, fields, message} = parse_args(args)
    {_, repo} = Ext.Utils.Repo.get_config(repo)
    message = if message, do: message, else: "Not unique"

    cond do
      schema |> repo.exists?(Map.take(form.changes, fields)) ->
        form |> add_error(List.first(fields), message)
      true ->
        form
    end
  end

  defp parse_args(args), do: {args[:schema], args[:repo], args[:fields], args[:message]}
end
