defmodule Status do
  use GenServer

  @refresh_frequency 1_000

  def start_link(_opts) do
    GenServer.start_link(__MODULE__, nil)
  end

  @impl true
  def init(_arg) do
    :ok
  end

  def draw do
    IO.write(IO.ANSI.clear())

    lines =
      ["Jubilee", "Circle", "District"]
      |> Enum.with_index(1)
      |> Enum.map(fn {line, index} ->
        IO.ANSI.cursor(index, 0) <> IO.ANSI.cyan_background() <> line <> IO.ANSI.reset()
      end)
      |> Enum.join("")

    IO.write(lines)

    :timer.sleep(@refresh_frequency)

    draw()
  end
end
