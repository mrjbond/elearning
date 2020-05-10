defmodule KV.V2 do
  @moduledoc """
  Version 1 of our key-value server.
  Implements a basic `receive` loop.

  Can be started as a named process.
  """

  require Logger

  @name __MODULE__

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
      nil -> {:error, :not_found}
      value when is_integer(value) -> {:ok, value}
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

  defp handle_message({:get, key, caller}, state) when is_atom(key) and is_pid(caller) do
    value = Map.get(state, key)
    send(caller, value)
    state
  end

  defp handle_message({:put, key, value}, state) when is_atom(key) and is_integer(value) do
    Map.put(state, key, value)
  end
end
