defmodule LineUpdatesTest.LineUpdateProducer do
  alias Events.LineUpdateEvent
  alias LineUpdates.LineUpdateProducer

  use AMQP
  use ExUnit.Case

  @amqp_url Application.get_env(:rabbit_mq, :amqp_url)

  setup_all do
    assert {:ok, connection} = Connection.open(@amqp_url)
    assert {:ok, channel} = Channel.open(connection)

    # Declare and bind an exclusive queue specific to this test module.
    # Will be automatically destroyed when the connection closes. 
    assert {:ok, %{queue: queue}} = Queue.declare(channel, "", exclusive: true)
    assert :ok = Queue.bind(channel, queue, "line_updates", routing_key: "#")

    on_exit(fn ->
      :ok = Channel.close(channel)
      :ok = Connection.close(connection)
    end)

    [channel: channel, queue: queue]
  end

  describe "#{__MODULE__}" do
    test "publish_event/2 produces a correctly configured event", %{
      channel: channel,
      queue: queue
    } do
      assert {:ok, consumer_tag} = Basic.consume(channel, queue)

      assert_receive({:basic_consume_ok, %{consumer_tag: ^consumer_tag}})

      line_id = Enum.random(~w(circle district victoria))

      event =
        LineUpdateEvent.new(
          {line_id, "Part suspended.", [id: UUID.uuid4(), inserted_at: DateTime.utc_now()]}
        )

      assert {:ok, _seq_no} = LineUpdateProducer.publish_event(event)

      correlation_id = event.event_id

      assert_receive(
        {:basic_deliver, payload,
         %{
           content_type: "application/json",
           correlation_id: ^correlation_id,
           delivery_tag: delivery_tag,
           routing_key: ^line_id
         }}
      )

      assert payload === Jason.encode!(event)

      assert :ok = Basic.ack(channel, delivery_tag)

      # Ensure no further messages are received by this process.
      refute_receive(_)

      {:ok, ^consumer_tag} = Basic.cancel(channel, consumer_tag)
    end
  end
end
