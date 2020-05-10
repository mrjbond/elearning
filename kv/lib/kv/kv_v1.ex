defmodule KV.V1 do
  @moduledoc """
  Version 1 of our key-value server.
  Implements a basic `receive` loop.
  """

  require Logger

  @doc """
  Dequeues messages from the mailbox, processes them, and sends a reply to the caller.

  New state is computed, with each `handle_message/1` and used to initialise the next `loop/1`.
  """
  def loop(state) when is_map(state) do
    receive do
      message -> message |> handle_message(state) |> loop()
    end
  end

  defp handle_message({:get, key, caller}, state) when is_atom(key) and is_pid(caller) do
    value = Map.get(state, key)
    send(caller, value)
    state
  end

  defp handle_message({:put, key, value, caller}, state)
       when is_atom(key) and is_integer(value) and is_pid(caller) do
    next_state = Map.put(state, key, value)
    send(caller, :ok)
    next_state
  end
end
