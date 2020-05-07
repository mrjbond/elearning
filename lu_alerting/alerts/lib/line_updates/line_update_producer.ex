defmodule LineUpdates.LineUpdateProducer do
  @moduledoc """
  Publishes pre-configured events onto the "line_updates" exchange.
  """

  alias Events.LineUpdate

  use RabbitMQ.Producer, exchange: "line_updates"

  def publish_line_update(%LineUpdate{} = event, opts) do
    opts =
      Keyword.merge(opts,
        content_type: "application/json"
        # mandatory: true
      )

    payload = Jason.encode!(event)

    publish(payload, "#{event.line_id}", opts)
  end

  @doc """
  In the unlikely event of a failed publisher confirm, messages that go
  unack'd will be passed onto this callback. You can use this to notify
  another process and deal with such exceptions in any way you like.
  """
  @impl true
  def handle_publisher_nack(unackd_messages) do
    Logger.error("Failed to publish messages: #{inspect(unackd_messages)}")
  end
end
