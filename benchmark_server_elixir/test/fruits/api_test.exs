defmodule BenchmarkServerTest do
  use ExUnit.Case
  doctest BenchmarkServer

  test "greets the world" do
    assert BenchmarkServer.hello() == :world
  end
end
