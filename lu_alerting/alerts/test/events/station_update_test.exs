defmodule EventsTest.StationUpdate do
  alias Events.StationUpdate

  use ExUnit.Case

  test "new/1 produces a pre-configured event" do
    alert_id = UUID.uuid4()

    attrs = %{
      id: alert_id,
      station_id: :westminster,
      category: :engineering_works,
      description: "Reduced escalator service due to planned engineering works."
    }

    assert %StationUpdate{
             e_v: "1.0.0",
             e_id: _,
             id: ^alert_id,
             created_at: _,
             station_id: :westminster,
             category: :engineering_works,
             description: "Reduced escalator service due to planned engineering works."
           } = StationUpdate.new(attrs)
  end
end
