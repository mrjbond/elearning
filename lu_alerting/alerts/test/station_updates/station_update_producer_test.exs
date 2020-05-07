defmodule StationUpdatesTest.StationUpdateProducer do
  alias Events.StationUpdate
  alias StationUpdates.StationUpdateProducer

  use AMQP
  use ExUnit.Case

  @amqp_url Application.get_env(:rabbit_mq, :amqp_url)
  @exchange "station_updates"

  setup_all do
    assert {:ok, connection} = Connection.open(@amqp_url)
    assert {:ok, channel} = Channel.open(connection)

    # Declare and bind an exclusive queue specific to this test module.
    # Will be automatically destroyed when the connection closes. 
    assert {:ok, %{queue: queue}} = Queue.declare(channel, "", exclusive: true)
    assert :ok = Queue.bind(channel, queue, @exchange, routing_key: "#")

    on_exit(fn ->
      :ok = Channel.close(channel)
      :ok = Connection.close(connection)
    end)

    [channel: channel, queue: queue]
  end

  setup do
    [correlation_id: UUID.uuid4()]
  end

  describe "#{__MODULE__}" do
    test "publish_station_update/2 produces a correctly configured event", %{
      channel: channel,
      correlation_id: correlation_id,
      queue: queue
    } do
      assert {:ok, consumer_tag} = Basic.consume(channel, queue)

      station_id =
        [:waterloo, :westminster]
        |> Enum.random()
        |> Atom.to_string()

      event =
        StationUpdate.new(%{
          id: UUID.uuid4(),
          station_id: station_id,
          category: :accessibility,
          description: "Reduced escalator service due to planned engineering works."
        })

      assert {:ok, _seq_no} =
               StationUpdateProducer.publish_station_update(event, correlation_id: correlation_id)

      assert_receive(
        {:basic_deliver, payload,
         %{
           content_type: "application/json",
           correlation_id: ^correlation_id,
           delivery_tag: delivery_tag,
           routing_key: ^station_id
         }}
      )

      assert payload === Jason.encode!(event)

      assert :ok = Basic.ack(channel, delivery_tag)

      {:ok, ^consumer_tag} = Basic.cancel(channel, consumer_tag)
    end
  end
end
