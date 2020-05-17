defmodule Producers.RabbitMQ.StationUpdatesProducer do
  use RabbitMQ.Producer, exchange: "station_updates"

  def handle_publisher_ack_confirms(_events), do: :ok
  def handle_publisher_nack_confirms(_events), do: :ok
end
