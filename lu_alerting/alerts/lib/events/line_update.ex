defmodule Events.LineUpdate do
  @derive Jason.Encoder
  @enforce_keys ~w(e_v e_id id created_at line_id category description)a
  defstruct @enforce_keys

  def suspension(attrs) do
    %__MODULE__{
      e_v: "1.0.0",
      e_id: UUID.uuid4(),
      id: attrs.id,
      created_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      line_id: attrs.line_id,
      category: :suspension,
      description: attrs.description
    }
  end

  def closure(attrs) do
    %__MODULE__{
      e_v: "1.0.0",
      e_id: UUID.uuid4(),
      id: attrs.id,
      created_at: DateTime.utc_now() |> DateTime.to_iso8601(),
      line_id: attrs.line_id,
      category: :closure,
      description: attrs.description
    }
  end

  # def special_service(attrs) do
  #   %__MODULE__{
  #     e_v: "1.0.0",
  #     e_id: UUID.uuid4(),
  #     id: attrs.id,
  #     created_at: DateTime.utc_now() |> DateTime.to_iso8601(),
  #     line_id: attrs.line_id,
  #     category: :special_service,
  #     description: attrs.description
  #   }
  # end

  # def delayed_service(attrs) do
  #   %__MODULE__{
  #     e_v: "1.0.0",
  #     e_id: UUID.uuid4(),
  #     id: attrs.id,
  #     created_at: DateTime.utc_now() |> DateTime.to_iso8601(),
  #     line_id: attrs.line_id,
  #     category: :delayed_service,
  #     severity: attrs.severity,
  #     description: attrs.description
  #   }
  # end
end
