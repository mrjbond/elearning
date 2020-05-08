defmodule EventsTest.StationUpdateEvent do
  alias Events.StationUpdateEvent

  use ExUnit.Case

  test "new/1 produces a pre-configured event" do
    meta = [id: UUID.uuid4(), inserted_at: DateTime.utc_now()]
    attrs = {:westminster, "Reduced escalator service.", meta}

    assert %StationUpdateEvent{
             event_id: _,
             event_version: "1.0.0",
             event_type: :station_update,
             event_created_at: _,
             id: id,
             inserted_at: inserted_at,
             station_id: :westminster,
             description: "Reduced escalator service."
           } = StationUpdateEvent.new(attrs)

    assert id === Keyword.get(meta, :id)
    assert inserted_at === meta |> Keyword.get(:inserted_at) |> DateTime.to_iso8601()
  end
end
