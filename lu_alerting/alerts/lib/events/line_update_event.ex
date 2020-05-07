defmodule Events.LineUpdateEvent do
  @derive Jason.Encoder
  @enforce_keys ~w(
    event_id
    event_version
    event_type
    event_created_at
    id
    inserted_at
    line_id
    description
  )a
  defstruct @enforce_keys

  @this_module __MODULE__

  def new({line_id, description, meta}) do
    id = Keyword.fetch!(meta, :id)
    inserted_at = Keyword.fetch!(meta, :inserted_at)

    %@this_module{
      event_id: UUID.uuid4(),
      event_version: "1.0.0",
      event_type: :line_update,
      event_created_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      id: id,
      inserted_at: inserted_at |> DateTime.to_iso8601(),
      line_id: line_id,
      description: description
    }
  end
end
