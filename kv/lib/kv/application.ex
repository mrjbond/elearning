defmodule KV.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications
  @moduledoc false

  use Application

  def start(_type, _args) do
    children = [
      {Task.Supervisor, name: TaskSupervisor},
      %{
        id: KV.V2.Supervised,
        start: {KV.V2, :start_link, [%{milk: 1, honey: 2}]}
      },
      {KV.V3, %{milk: 1, honey: 2}}
    ]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KV.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
