defmodule StatusUpdatesTest.PerpetualUpdater do
  alias StatusUpdates.PerpetualUpdater
  alias LineUpdates.Registry, as: LineUpdatesRegistry
  alias StationUpdates.Registry, as: StationUpdatesRegistry

  use AMQP
  use ExUnit.Case, async: false

  @amqp_url Application.get_env(:rabbit_mq, :amqp_url)

  setup_all do
    assert {:ok, connection} = Connection.open(@amqp_url)
    assert {:ok, channel} = Channel.open(connection)

    # Declare and bind an exclusive queue specific to this test module.
    # Will be automatically destroyed when the connection closes. 
    assert {:ok, %{queue: station_updates_queue}} = Queue.declare(channel, "", exclusive: true)
    assert :ok = Queue.bind(channel, station_updates_queue, "station_updates", routing_key: "#")
    assert {:ok, %{queue: line_updates_queue}} = Queue.declare(channel, "", exclusive: true)
    assert :ok = Queue.bind(channel, line_updates_queue, "line_updates", routing_key: "#")

    on_exit(fn ->
      :ok = Channel.close(channel)
      :ok = Connection.close(connection)
    end)

    [
      channel: channel,
      station_updates_queue: station_updates_queue,
      line_updates_queue: line_updates_queue
    ]
  end

  describe "#{__MODULE__}" do
    test ":push_updates checks for combined updates, publishes them one by one", %{
      channel: channel,
      station_updates_queue: station_updates_queue,
      line_updates_queue: line_updates_queue
    } do
      assert {:ok, station_updates_consumer_tag} = Basic.consume(channel, station_updates_queue)
      assert {:ok, line_updates_consumer_tag} = Basic.consume(channel, line_updates_queue)

      assert_receive({:basic_consume_ok, %{consumer_tag: ^station_updates_consumer_tag}})
      assert_receive({:basic_consume_ok, %{consumer_tag: ^line_updates_consumer_tag}})

      assert {:ok, _meta} = LineUpdatesRegistry.put(:bakerloo, "Part suspended.")
      assert {:ok, _meta} = StationUpdatesRegistry.put(:westminster, "Reduced escalator service.")

      send(PerpetualUpdater, :push_updates)

      assert_receive(
        {:basic_deliver, _payload,
         %{
           consumer_tag: ^station_updates_consumer_tag,
           content_type: "application/json",
           delivery_tag: delivery_tag,
           routing_key: "westminster"
         }}
      )

      assert :ok = Basic.ack(channel, delivery_tag)

      assert_receive(
        {:basic_deliver, _payload,
         %{
           consumer_tag: ^line_updates_consumer_tag,
           content_type: "application/json",
           delivery_tag: delivery_tag,
           routing_key: "bakerloo"
         }}
      )

      assert :ok = Basic.ack(channel, delivery_tag)

      # Ensure no further messages are received by this process.
      refute_receive(_)

      assert :ok = LineUpdatesRegistry.clear(:bakerloo)
      assert :ok = StationUpdatesRegistry.clear(:westminster)

      {:ok, ^station_updates_consumer_tag} = Basic.cancel(channel, station_updates_consumer_tag)
      {:ok, ^line_updates_consumer_tag} = Basic.cancel(channel, line_updates_consumer_tag)
    end
  end
end
