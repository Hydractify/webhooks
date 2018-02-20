defmodule Webhooks.MixProject do
  use Mix.Project

  def project do
    [
      app: :webhooks,
      version: "0.1.0",
      elixir: "~> 1.6",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Webhooks.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:cowboy, "~> 1.1"},
      {:plug, "~> 1.4.5"},
      {:poison, "~> 3.1.0"},
      {:redix, "~> 0.7.0"}
    ]
  end
end
