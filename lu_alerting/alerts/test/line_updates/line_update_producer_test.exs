defmodule LineUpdatesTest.LineUpdateProducer do
  alias Events.LineUpdate
  alias LineUpdates.LineUpdateProducer

  use AMQP
  use ExUnit.Case

  @amqp_url Application.get_env(:rabbit_mq, :amqp_url)
  @exchange "line_updates"

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
    test "publish_line_update/2 produces a correctly configured event", %{
      channel: channel,
      correlation_id: correlation_id,
      queue: queue
    } do
      assert {:ok, consumer_tag} = Basic.consume(channel, queue)

      line_id =
        [:circle, :victoria]
        |> Enum.random()
        |> Atom.to_string()

      event =
        LineUpdate.closure(%{
          id: UUID.uuid4(),
          line_id: line_id,
          description: "The #{line_id} line is closed."
        })

      assert {:ok, _seq_no} =
               LineUpdateProducer.publish_line_update(event, correlation_id: correlation_id)

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

      {:ok, ^consumer_tag} = Basic.cancel(channel, consumer_tag)
    end
  end
end
