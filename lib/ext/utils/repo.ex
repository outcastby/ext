defmodule Ext.Utils.Repo do
  def get_config(repo) do
    app_name = Mix.Project.config()[:app]
    repo = if repo, do: repo, else: Application.get_env(app_name, :ecto_repos) |> List.first()
    {app_name, repo}
  end

  def generate_uniq_hash(schema, column, length \\ 35) do
    hash = :crypto.strong_rand_bytes(length) |> Base.url_encode64()

    result = schema |> Arcade.Repo.exists?(%{column => hash})

    cond do
      result -> generate_uniq_hash(schema, column, length)
      true -> hash
    end
  end
end
