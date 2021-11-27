defmodule AlgoliaElixir.MixProject do
  use Mix.Project

  def project do
    [
      app: :algolia_elixir,
      version: "0.1.0",
      elixir: "~> 1.12",
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
      {:hackney, "~> 1.17"},
      {:jason, ">= 1.0.0"},
      {:tesla, "~> 1.4"}
    ]
  end
end
