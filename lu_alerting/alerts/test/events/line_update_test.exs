defmodule EventsTest.LineUpdateEvent do
  alias Events.LineUpdateEvent

  use ExUnit.Case

  test "new/1 produces a pre-configured event" do
    meta = [id: UUID.uuid4(), inserted_at: DateTime.utc_now()]
    attrs = {:circle, "The Circle line is part suspended.", meta}

    assert %LineUpdateEvent{
             event_id: _,
             event_version: "1.0.0",
             event_type: :line_update,
             event_created_at: _,
             id: id,
             inserted_at: inserted_at,
             line_id: :circle,
             description: "The Circle line is part suspended."
           } = LineUpdateEvent.new(attrs)

    assert id === Keyword.get(meta, :id)
    assert inserted_at === meta |> Keyword.get(:inserted_at) |> DateTime.to_iso8601()
  end
end
