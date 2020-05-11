defmodule BenchmarkServer.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  @cowboy_opts [port: 4000, transport_options: [num_acceptors: 10, max_connections: :infinity]]

  def start(_type, _args) do
    children = [
      {Plug.Cowboy, scheme: :http, plug: BenchmarkServer.Router, options: @cowboy_opts}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: BenchmarkServer.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
