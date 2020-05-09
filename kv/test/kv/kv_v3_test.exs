defmodule KVTest do
  use ExUnit.Case

  test "get/1 gets the value if it exists" do
    assert :ok = GenServer.cast(KV.V3, {:put, :figs, 42})
    assert {:ok, 42} = KV.V3.get(:figs)
    # TODO perform cleanup, can be part of setup
  end

  test "get/1 returns an error if the value cannot be found" do
    assert {:error, :not_found} = KV.V3.get(:non_existent_value)
  end

  test "put/2 inserts a value if it does not exist" do
    # Ensure there is no entry for apples
    assert {:error, :not_found} = KV.V3.get(:apples)

    assert :ok = KV.V3.put(:apples, 3)

    # Sleep as this is an asynchronous op
    :timer.sleep(1)

    assert {:ok, 3} = KV.V3.get(:apples)
  end

  test "put/2 updates a value if it exists" do
    # Ensure there is an existing entry for apples
    assert :ok = GenServer.cast(KV.V3, {:put, :peppers, 9})
    :timer.sleep(1)
    assert {:ok, 9} = KV.V3.get(:peppers)

    assert :ok = KV.V3.put(:peppers, 365)

    # Sleep as this is an asynchronous op
    :timer.sleep(1)

    assert {:ok, 365} = KV.V3.get(:peppers)
  end
end
