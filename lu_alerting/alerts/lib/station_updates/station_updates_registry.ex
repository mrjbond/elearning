defmodule StationUpdates.Registry do
  use GenServer

  @stations ~w(
    westminster
    waterloo
    victoria
    heathrow_terminal_1_2_3
    heathrow_terminal_4
    heathrow_terminal_5
    elephant_and_castle
    old_street
    camden_town
  )a

  @this_module __MODULE__

  defmodule State do
    @enforce_keys ~w(registry)a
    defstruct @enforce_keys
  end

  def start_link(_opts) do
    GenServer.start_link(@this_module, nil, name: @this_module)
  end

  def put(station_id, description) do
    GenServer.call(@this_module, {:put_update, station_id, description})
  end

  def clear(station_id) do
    GenServer.call(@this_module, {:clear_update, station_id})
  end

  def list() do
    GenServer.call(@this_module, :list_updates)
  end

  @impl true
  def init(nil) do
    registry = :ets.new(:registry, [:set, :protected])
    {:ok, %State{registry: registry}}
  end

  @impl true
  def handle_call(
        {:put_update, station_id, description},
        _from,
        %State{registry: registry} = state
      )
      when station_id in @stations and is_binary(description) do
    meta = [id: UUID.uuid4(), inserted_at: DateTime.utc_now()]
    true = :ets.insert(registry, {station_id, description, meta})
    {:reply, {:ok, meta}, state}
  end

  @impl true
  def handle_call(
        {:clear_update, station_id},
        _from,
        %State{registry: registry} = state
      )
      when station_id in @stations do
    true = :ets.delete(registry, station_id)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:list_updates, _from, %State{registry: registry} = state) do
    {:reply, :ets.tab2list(registry), state}
  end
end
