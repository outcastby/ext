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

    %{context | args: args}
  end

  def skip_release_tag(args, %{version: version, prev_version: prev_version, env_name: env_name})
      when version == prev_version or env_name != "prod" do
    Helper.puts("Tag release is skipped")
    args ++ ["--skip-tags", "release"]
  end

  def skip_release_tag(args, _), do: args

  def skip_job_tag(args, true) do
    Helper.puts("Job is skipped")
    args ++ ["--skip-tags", "job"]
  end

  def skip_job_tag(args, _), do: args
end
