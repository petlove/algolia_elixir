defmodule AlgoliaElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :algolia_elixir,
      version: "0.1.1",
      elixir: "~> 1.12",
      elixirc_paths: elixirc_paths(Mix.env()),
      start_permanent: Mix.env() == :prod,
      deps: deps(),
      test_coverage: [tool: ExCoveralls],
      preferred_cli_env: [
        coveralls: :test,
        "coveralls.detail": :test,
        "coveralls.post": :test,
        "coveralls.html": :test
      ]
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger]
    ]
  end

  defp elixirc_paths(:test), do: ["lib", "test/support"]
  defp elixirc_paths(_), do: ["lib"]

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:ex_machina, "~> 2.7.0", only: :test},
      {:excoveralls, "~> 0.10", only: :test},
      {:faker, "~> 0.17", only: :test},
      {:hackney, "~> 1.17"},
      {:jason, ">= 1.0.0"},
      {:tesla, "~> 1.4"}
    ]
  end
end
