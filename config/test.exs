use Mix.Config

config :ext,
  ecto_repos: [TestRepo]

config :ext, :ext, slack_token: "slack_token"

config :ext, :for_test, slack: [token: "slack_token"], docker: %{user_name: "user_name"}
