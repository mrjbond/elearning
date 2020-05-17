defmodule Benchmarks do
  # Random 2kB string
  @data :crypto.strong_rand_bytes(2_000) |> Base.encode64()
  @routing_key "westminster"
  @publish_opts []

  def run(:gen_rmq, count) do
    benchmark = fn ->
      1..count
      |> Task.async_stream(fn _index ->
        GenRMQ.Publisher.publish(
          Producers.GenRMQ.StationUpdatesProducer,
          @data,
          @routing_key,
          @publish_opts
        )
      end)
      |> Enum.to_list()
    end

    measure(benchmark)
  end

  def run(:rabbit_mq, count) do
    benchmark = fn ->
      1..count
      |> Task.async_stream(fn _index ->
        Producers.RabbitMQ.StationUpdatesProducer.publish(@routing_key, @data, @publish_opts)
      end)
      |> Enum.to_list()
    end

    measure(benchmark)
  end

  defp measure(function) do
    function
    |> :timer.tc()
    |> elem(0)
    |> Integer.to_string()
    |> Kernel.<>("μs")
  end
end
