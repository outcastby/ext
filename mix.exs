defmodule Ext.MixProject do
  use Mix.Project

  def project do
    [
      app: :ext,
      version: "0.1.0",
      elixir: "~> 1.7",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ecto_sql, "~> 3.0-rc"},
      {:atomic_map, "~> 0.8"},
      {:timex, "~> 3.1"},
      {:absinthe, "~> 1.4.0"},
      {:proper_case, "~> 1.0.2"},
      {:jason, "~> 1.0"},
      {:httpoison, "~> 1.4.0"},
      {:blankable, "~> 0.0.1"},
      {:neuron, "~> 1.0.0"},
      {:postgrex, ">= 0.0.0-rc"}
    ]
  end
end
