defmodule Alerting.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      Producers.RabbitMQ.StationUpdatesProducer,
      %{
        id: Producers.GenRMQ.StationUpdatesProducer,
        start:
          {GenRMQ.Publisher, :start_link,
           [
             Producers.GenRMQ.StationUpdatesProducer,
             [name: Producers.GenRMQ.StationUpdatesProducer]
           ]}
      }
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: Alerting.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
