defmodule Dummy.Application do
  use Application

  def start(_type, _args) do
    # port = String.to_integer(System.get_env("PORT") || "4040")

    children = [
      {Task.Supervisor, name: Dummy.TaskSupervisor}
      # {Task, fn -> KVServer.accept(port) end}
    ]

    opts = [strategy: :one_for_one, name: Dummy.Supervisor]
    Supervisor.start_link(children, opts)
  end
end
