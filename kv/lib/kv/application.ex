defmodule KV.Application do
  # See https://hexdocs.pm/elixir/Application.html
  # for more information on OTP Applications

  @moduledoc false

  @initial_state %{milk: 42, honey: 314}

  use Application

  def start(_type, _args) do
    children = Enum.map(1..100, &child_spec/1)
    children = [{Task.Supervisor, name: TaskSupervisor} | children]

    # See https://hexdocs.pm/elixir/Supervisor.html
    # for other strategies and supported options
    opts = [strategy: :one_for_one, name: KV.Supervisor]
    Supervisor.start_link(children, opts)
  end

  defp child_spec(index) do
    %{
      id: index,
      start: {KV, :start_link, [@initial_state]}
    }
  end
end
