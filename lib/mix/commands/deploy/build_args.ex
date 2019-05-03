defmodule Mix.Commands.Deploy.BuildArgs do
  alias Mix.Commands.Deploy
  alias Mix.Helper

  def call(context, is_fast) do
    %{version: version, prev_version: prev_version, tag: tag, prev_tag: prev_tag, env_name: env_name} = context

    args =
      [
        "-i",
        "inventory",
        "playbook.yml",
        "--extra-vars",
        "env_name=#{env_name} image_tag=#{tag} version=#{version} prev_image_tag=#{prev_tag} prev_version=#{
          prev_version
        }"
      ]
      |> skip_release_tag(context)
      |> skip_job_tag(is_fast)

    Deploy.Context.update(context, %{args: args})
  end

  def skip_release_tag(args, %{version: version, prev_version: prev_version, env_name: env_name} = context) do
    cond do
      version == prev_version || env_name != "prod" ->
        Helper.puts("Tag release is skipped")
        args ++ ["--skip-tags", "release"]

      true ->
        args
    end
  end

  def skip_job_tag(args, is_fast) do
    cond do
      is_fast ->
        Helper.puts("Job is skipped")
        args ++ ["--skip-tags", "job"]

      true ->
        args
    end
  end
end
