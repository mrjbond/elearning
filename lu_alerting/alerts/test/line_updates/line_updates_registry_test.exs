defmodule LineUpdatesTest.Registry do
  alias LineUpdates.Registry

  use ExUnit.Case, async: false

  describe "#{__MODULE__}" do
    test "starts an empty registry" do
      assert [] = Registry.list()
    end

    test "put/2 creates an entry if it does not exist" do
      assert {:ok, meta} = Registry.put(:central, "Part suspended.")
      assert [{:central, "Part suspended.", ^meta}] = Registry.list()
      assert :ok = Registry.clear(:central)
    end

    test "put/2 updates an entry if it already exists" do
      assert {:ok, meta} = Registry.put(:central, "Part suspended.")
      assert [{:central, "Part suspended.", ^meta}] = Registry.list()

      assert {:ok, meta_updated} = Registry.put(:central, "Suspended.")
      assert [{:central, "Suspended.", ^meta_updated}] = Registry.list()

      assert meta !== meta_updated

      assert :ok = Registry.clear(:central)
    end
  end
end
