defmodule EventsTest.LineUpdate do
  alias Events.LineUpdate

  use ExUnit.Case

  test "suspension/1 produces a pre-configured event" do
    alert_id = UUID.uuid4()

    attrs = %{
      id: alert_id,
      line_id: :circle,
      description: "The Circle line is part suspended."
    }

    assert %LineUpdate{
             e_v: "1.0.0",
             e_id: _,
             id: ^alert_id,
             created_at: _,
             line_id: :circle,
             category: :suspension,
             description: "The Circle line is part suspended."
           } = LineUpdate.suspension(attrs)
  end

  test "closure/1 produces a pre-configured event" do
    alert_id = UUID.uuid4()

    attrs = %{
      id: alert_id,
      line_id: :victoria,
      description: "The Victoria line is part suspended."
    }

    assert %LineUpdate{
             e_v: "1.0.0",
             e_id: _,
             id: ^alert_id,
             created_at: _,
             line_id: :victoria,
             category: :closure,
             description: "The Victoria line is part suspended."
           } = LineUpdate.closure(attrs)
  end
end
