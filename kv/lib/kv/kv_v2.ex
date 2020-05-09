defmodule KV.V2 do
  @moduledoc """
  V2 of the Key-Value server.

  Can be started as a named process.

  Uses a simple `receive` loop to:

  1. process a request
  2. send back a reply
  """

  require Logger

  @name :kv_v2

  @doc """
  Starts and registers the process, uses `spawn_link/1`.
  """
  def start_link(initial_state) when is_map(initial_state) do
    pid = spawn_link(fn -> loop(initial_state) end)

    Process.register(pid, @name)

    {:ok, pid}
  end

  # Public APIs

  def get(key) when is_atom(key) do
    caller = self()

    pid = spawn_link(fn -> send(@name, {:get, key, caller}) end)

    receive do
      msg -> msg
    after
      5_000 ->
        Process.exit(pid, :kill)
        {:error, :timeout}
    end
  end

  def put(key, value) when is_atom(key) and is_integer(value) do
    _ = spawn(fn -> send(@name, {:put, key, value}) end)
    :ok
  end

  # Private functions

  defp loop(state) do
    receive do
      message -> message |> handle_message(state) |> loop()
    end
  end

  defp handle_message({:get, key, from}, state) do
    state
    |> Map.get(key)
    |> case do
      value when is_integer(value) -> {:ok, value}
      _ -> {:error, :not_found}
    end
    |> (&send(from, &1)).()

    state
  end

  defp handle_message({:put, key, value}, state) do
    Map.put(state, key, value)
  end
end
