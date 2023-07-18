defmodule PostfinanceScraper.MixProject do
  use Mix.Project

  def project do
    [
      app: :postfinance_scraper,
      version: "0.1.0",
      elixir: "~> 1.14",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {PostfinanceScraper.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:dotenvy, "~> 0.8.0"},
      {:httpoison, "~> 2.1"},
      {:wallaby, "~> 0.30.4"}
    ]
  end
end
