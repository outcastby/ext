defmodule Mix.Commands.Deploy.Context do
  alias Mix.Helper
  import Ext.Utils.Map
  defstruct [:env_name, :tag, :version, :prev_tag, :prev_version, :args]

  def init("prod" = env_name, tag),
    do: %{tag: tag, version: nil, prev_version: nil, prev_tag: nil, env_name: env_name, args: []}

  def init(env_name, tag) do
    version = deploy_version(tag)
    {prev_version, prev_tag} = server_version_and_image_tag(env_name)
    {version, prev_version} = if version > prev_version, do: {version, prev_version}, else: {prev_version, version}
    {tag, prev_tag} = if version > prev_version, do: {tag, prev_tag}, else: {prev_tag, tag}
    %{version: version, prev_version: prev_version, tag: tag, prev_tag: prev_tag, env_name: env_name, args: []}
  end

  def update(context, updated_map), do: context ||| updated_map

  def deploy_version(image), do: Helper.parse_tag_version(image)

  def server_version_and_image_tag(env_name) do
    # curl https://arcade.prod.server-planet-gold-rush.com/info
    args = [String.replace(Helper.settings()[:build_info_path], ":env_name:", env_name)]
    {message, status} = System.cmd(System.find_executable("curl"), args)

    case status do
      0 ->
        image = Poison.decode!(message)["image"]["name"]
        {Helper.parse_tag_version(image), image}

      _ ->
        {nil, nil}
    end
  end
end
