defmodule Alerting.MixProject do
  use Mix.Project

  def project do
    [
      app: :alerting,
      version: "0.1.0",
      elixir: "~> 1.10",
      start_permanent: Mix.env() == :prod,
      deps: deps()
    ]
  end

  # Run "mix help compile.app" to learn about applications.
  def application do
    [
      extra_applications: [:logger],
      mod: {Alerting.Application, []}
    ]
  end

  # Run "mix help deps" to learn about dependencies.
  defp deps do
    [
      {:gen_rmq, "~> 2.6.1"},
      {:rabbit_mq, "~> 0.0.19"},
      {:benchee, "~> 1.0", only: :dev}
    ]
  end
end
