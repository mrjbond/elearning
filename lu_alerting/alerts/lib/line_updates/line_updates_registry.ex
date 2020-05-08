defmodule LineUpdates.Registry do
  use GenServer

  @lines ~w(
    bakerloo
    central
    circle
    district
    hammersmith_and_city
    jubilee
    metropolitan
    northern
    picadilly
    victoria
    waterloo_and_city
  )a

  @this_module __MODULE__

  defmodule State do
    @enforce_keys ~w(registry)a
    defstruct @enforce_keys
  end

  def start_link(_opts) do
    GenServer.start_link(@this_module, nil, name: @this_module)
  end

  def put(line_id, description) do
    GenServer.call(@this_module, {:put_update, line_id, description})
  end

  def clear(line_id) do
    GenServer.call(@this_module, {:clear_update, line_id})
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
  def handle_call({:put_update, line_id, description}, _from, %State{registry: registry} = state)
      when line_id in @lines and is_binary(description) do
    meta = [id: UUID.uuid4(), inserted_at: DateTime.utc_now()]
    true = :ets.insert(registry, {line_id, description, meta})
    {:reply, {:ok, meta}, state}
  end

  @impl true
  def handle_call(
        {:clear_update, line_id},
        _from,
        %State{registry: registry} = state
      )
      when line_id in @lines do
    true = :ets.delete(registry, line_id)
    {:reply, :ok, state}
  end

  @impl true
  def handle_call(:list_updates, _from, %State{registry: registry} = state) do
    {:reply, :ets.tab2list(registry), state}
  end
end
