defmodule StationUpdatesTest.Registry do
  alias StationUpdates.Registry

  use ExUnit.Case, async: false

  describe "#{__MODULE__}" do
    test "starts an empty registry" do
      assert [] = Registry.list()
    end

    test "put/2 creates an entry if it does not exist" do
      assert {:ok, meta} = Registry.put(:westminster, "Reduced escalator service.")
      assert [{:westminster, "Reduced escalator service.", ^meta}] = Registry.list()
      assert :ok = Registry.clear(:westminster)
    end

    test "put/2 updates an entry if it already exists" do
      assert {:ok, meta} = Registry.put(:westminster, "Reduced escalator service.")
      assert [{:westminster, "Reduced escalator service.", ^meta}] = Registry.list()

      assert {:ok, meta_updated} = Registry.put(:westminster, "No escalator service.")
      assert [{:westminster, "No escalator service.", ^meta_updated}] = Registry.list()

      assert meta !== meta_updated

      assert :ok = Registry.clear(:westminster)
    end
  end
end
