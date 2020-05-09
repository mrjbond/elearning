defmodule KV.V1 do
  @moduledoc """
  V1 of the Key-Value server.

  Uses a simple `receive` loop to:

  1. process a request
  2. send back a reply
  """

  require Logger

  @doc """
  Dequeues messages from the process mailbox through a `receive` loop.
  """
  def loop(state) when is_map(state) do
    Logger.info("State is #{inspect(state)}")

    receive do
      {:get, key, caller} ->
        Logger.debug("Get #{key}")
        value = Map.get(state, key)
        send(caller, value)
        loop(state)

      {:put, key, value, caller} ->
        Logger.debug("Put #{key}: #{value}")
        next_state = Map.put(state, key, value)
        send(caller, next_state)
        loop(next_state)

      message ->
        Logger.warn("Received unknown message: #{inspect(message)}")
        loop(state)
    end
  end
end
