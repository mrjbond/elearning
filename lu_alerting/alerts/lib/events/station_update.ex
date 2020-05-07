defmodule Events.StationUpdate do
  @derive Jason.Encoder
  @enforce_keys ~w(e_v e_id id created_at station_id category description)a
  defstruct @enforce_keys

  def new(attrs) do
    %__MODULE__{
      e_v: "1.0.0",
      e_id: UUID.uuid4(),
      id: attrs.id,
      created_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      station_id: attrs.station_id,
      category: attrs.category,
      description: attrs.description
    }
  end
end
