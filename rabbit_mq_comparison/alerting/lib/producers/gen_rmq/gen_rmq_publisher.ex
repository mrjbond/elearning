defmodule Producers.GenRMQ.StationUpdatesProducer do
  @amqp_url "amqp://guest:guest@localhost:5672"
  @behaviour GenRMQ.Publisher

  def init() do
    [
      connection: @amqp_url,
      enable_confirmations: true,
      exchange: {:direct, "station_updates"}
    ]
  end
end
