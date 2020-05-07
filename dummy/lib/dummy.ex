defmodule Dummy do
  @moduledoc """
  Documentation for `Dummy`.

  This is where we will define some cool functions.
  """

  require Logger

  @doc """
  Hello world.

  ## Examples

      iex> Dummy.hello()
      :world

  """
  def hello do
    :world
  end

  def world do
    :hello
  end

  @doc """
  Sums the elements in a list, provided these are integers.
  """
  def sum([]), do: 0

  def sum(list) when is_list(list), do: sum(list, 0)

  def sum([head | tail], acc) when is_integer(head) and is_integer(acc) do
    sum(tail, acc + head)
  end

  def sum([], acc), do: acc

  def receive_loop() do
    receive do
      :hello -> Logger.info("Hi!")
      _ -> raise "Unknown message, bro!"
    end

    receive_loop()
  end
end
