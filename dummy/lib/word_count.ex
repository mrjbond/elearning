defmodule Dummy.WordCount do
  def enum do
    File.stream!("./the_bible")
    |> Enum.flat_map(&String.split(&1, " "))
    |> Enum.reduce(%{}, fn word, acc ->
      Map.update(acc, word, 1, &(&1 + 1))
    end)
    |> Enum.to_list()
  end

  def stream do
    File.stream!("./the_bible")
    |> Stream.flat_map(&String.split(&1, " "))
    |> Enum.reduce(%{}, fn word, acc ->
      Map.update(acc, word, 1, &(&1 + 1))
    end)
    |> Enum.to_list()
  end

  def flow do
    File.stream!("./the_bible")
    |> Flow.from_enumerable()
    |> Flow.flat_map(&String.split(&1, " "))
    |> Flow.partition()
    |> Flow.reduce(fn -> %{} end, fn word, acc ->
      Map.update(acc, word, 1, &(&1 + 1))
    end)
    |> Enum.to_list()
  end
end
