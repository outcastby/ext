defmodule Mix.Commands.Deploy.Context do
  alias Mix.Helper
  defstruct [:env_name, :tag, :version, :prev_tag, :prev_version, args: []]

  def init("prod", tag), do: %__MODULE__{tag: tag, env_name: "prod"}

  def init(env_name, tag) do
    version = Helper.parse_tag_version(tag)
    {prev_version, prev_tag} = current_server_state(env_name)

    %__MODULE__{version: version, prev_version: prev_version, tag: tag, prev_tag: prev_tag, env_name: env_name}
  end

  def current_server_state(env_name) do
    # curl https://arcade.prod.server-planet-gold-rush.com/info
    args = [String.replace(Helper.settings()[:build_info_path], ":env_name:", env_name)]

    case System.cmd(System.find_executable("curl"), args) do
      {message, 0} ->
        image = Jason.decode!(message)["image"]["name"]
        {Helper.parse_tag_version(image), image}

      _ ->
        {nil, nil}
    end
  end
end
