defmodule StationWestminster.LineUpdatesConsumers do
  use Supervisor

  @lines [Jubilee, District, Circle]

  for line <- @lines do
    module = Module.concat(__MODULE__, line)
    routing_key = Macro.underscore(line)

    contents =
      quote do
        use RabbitMQ.Consumer,
          queue: {"line_updates", unquote(routing_key), "#{__MODULE__}"},
          worker_count: 1,
          prefetch_count: 3

        def handle_message(payload, meta, channel) do
          %{delivery_tag: delivery_tag, redelivered: redelivered} = meta

          try do
            Logger.info("Line update received: #{payload}.")
            ack(channel, delivery_tag)
          rescue
            _ -> nack(channel, delivery_tag, requeue: redelivered !== true)
          end
        end
      end

    Module.create(module, contents, Macro.Env.location(__ENV__))
  end

  def start_link(_opts) do
    opts = [name: Module.concat(__MODULE__, Supervisor)]
    Supervisor.start_link(__MODULE__, nil, opts)
  end

  def init(nil) do
    children =
      @lines
      |> Enum.map(&Module.concat(__MODULE__, &1))

    opts = [strategy: :one_for_one]
    Supervisor.init(children, opts)
  end
end
