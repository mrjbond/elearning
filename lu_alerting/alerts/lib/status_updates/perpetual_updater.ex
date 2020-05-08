defmodule StatusUpdates.PerpetualUpdater do
  alias Events.{LineUpdateEvent, StationUpdateEvent}
  alias LineUpdates.Registry, as: LineUpdatesRegistry
  alias LineUpdates.LineUpdateProducer, as: LineUpdateProducer
  alias StationUpdates.Registry, as: StationUpdatesRegistry
  alias StationUpdates.StationUpdateProducer, as: StationUpdateProducer

  use GenServer

  @push_interval 10_000
  @this_module __MODULE__

  def start_link(_opts) do
    GenServer.start_link(@this_module, nil, name: @this_module)
  end

  @impl true
  def init(nil) do
    _ref = Process.send_after(@this_module, :push_updates, @push_interval)
    {:ok, nil}
  end

  @impl true
  def handle_info(:push_updates, nil) do
    line_updates = LineUpdatesRegistry.list() |> Enum.map(&LineUpdateEvent.new/1)
    station_updates = StationUpdatesRegistry.list() |> Enum.map(&StationUpdateEvent.new/1)

    # See https://hexdocs.pm/elixir/Task.Supervisor.html#async_stream/6-options
    # for detailed breakdown of all available options.
    opts = [on_timeout: :kill_task, shutdown: :brutal_kill]

    [line_updates, station_updates]
    |> Stream.flat_map(&Function.identity/1)
    |> (&Task.Supervisor.async_stream(TaskSupervisor, &1, fn e -> do_publish(e) end, opts)).()
    |> Stream.run()

    Process.send_after(@this_module, :push_updates, @push_interval)

    {:noreply, nil}
  end

  defp do_publish(%LineUpdateEvent{} = event) do
    {:ok, _seq_no} = LineUpdateProducer.publish_event(event)
  end

  defp do_publish(%StationUpdateEvent{} = event) do
    {:ok, _seq_no} = StationUpdateProducer.publish_event(event)
  end
end
