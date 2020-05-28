defmodule Counter do
  use GenServer

  require Logger

  @this_module __MODULE__
  @timeout 1_000

  def start_link(initial_count) when is_integer(initial_count) do
    GenServer.start_link(@this_module, initial_count, name: @this_module)
  end

  def init(initial_count) do
    Process.send_after(self(), :increment, @timeout)
    {:ok, initial_count}
  end

  def handle_info(:increment, count) do
    next_count = count + 1
    Logger.info("New count: #{next_count}")
    Process.send_after(self(), :increment, @timeout)
    {:noreply, next_count}
  end
end
