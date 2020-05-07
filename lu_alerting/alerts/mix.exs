defmodule Alerts.MixProject do
  use Mix.Project

  def project do
    [
      app: :alerts,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:lager, :logger],
      mod: {Alerts.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:jason, "~> 1.2"},
      {:rabbit_mq, "~> 0.0.15"},
      {:uuid, "~> 1.1"}
    ]
  end
end
