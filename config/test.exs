use Mix.Config

config :ext,
  ecto_repos: [TestRepo]

config :ext, :ext, slack_token: "slack_token"
