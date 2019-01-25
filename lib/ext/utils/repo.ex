defmodule Ext.Utils.Repo do
  def get_config(repo) do
    app_name = Mix.Project.config()[:app]
    repo = if repo, do: repo, else: Application.get_env(app_name, :ecto_repos) |> List.first()
    {app_name, repo}
  end
end
