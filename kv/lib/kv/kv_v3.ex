defmodule KV.V3 do
  @moduledoc """
  V3 of the Key-Value server.

  Implemented as a `GenServer`.
  """

  require Logger

  use GenServer

  @this_module __MODULE__

  @doc """
  Starts this module as a named `GenServer`.
  """
  def start_link(initial_state) when is_map(initial_state) do
    GenServer.start_link(@this_module, initial_state, name: @this_module)
  end

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  # Public APIs

  def get(key) when is_atom(key) do
    GenServer.call(@this_module, {:get, key})
  end

  def put(key, value) when is_atom(key) and is_integer(value) do
    GenServer.cast(@this_module, {:put, key, value})
  end

  # GenServer Callbacks

  @impl true
  def handle_call({:get, key}, _from, state) do
    reply =
      state
      |> Map.get(key)
      |> case do
        value when is_integer(value) -> {:ok, value}
        _ -> {:error, :not_found}
      end

    {:reply, reply, state}
  end

  @impl true
  def handle_cast({:put, key, value}, state) do
    next_state = Map.put(state, key, value)
    {:noreply, next_state}
  end
end
