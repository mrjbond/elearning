defmodule KV do
  @moduledoc """
  Key-Value server implemented as a `GenServer`.
  """

  require Logger

  use GenServer

  @this_module __MODULE__

  @doc """
  Starts this module as `GenServer`.

  The process won't be named so that we can start as many as we like.
  """
  def start_link(initial_state) when is_map(initial_state) do
    GenServer.start_link(@this_module, initial_state)
  end

  @impl true
  def init(initial_state) do
    {:ok, initial_state}
  end

  # Public APIs

  def get(name, key) when is_atom(key) do
    GenServer.call(name, {:get, key})
  end

  def put(name, key, value) when is_atom(key) and is_integer(value) do
    GenServer.cast(name, {:put, key, value})
  end

  # GenServer Callbacks

  @impl true
  def handle_call({:get, key}, _from, state) do
    Logger.debug("[#{inspect(node())}] Get #{key}...")

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
    Logger.debug("[#{inspect(node())}] Set #{key}: #{value}...")

    next_state = Map.put(state, key, value)
    {:noreply, next_state}
  end
end
