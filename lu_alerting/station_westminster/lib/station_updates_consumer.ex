defmodule StationWestminster.StationUpdatesConsumer do
  use RabbitMQ.Consumer,
    queue: {"station_updates", "westminster", "#{__MODULE__}"},
    worker_count: 2

  require Logger

  def handle_message(payload, meta, channel) do
    %{delivery_tag: delivery_tag, redelivered: redelivered} = meta

    try do
      Logger.info("Station update received: #{payload}.")
      ack(channel, delivery_tag)
    rescue
      _ -> nack(channel, delivery_tag, requeue: redelivered !== true)
    end
  end
end
