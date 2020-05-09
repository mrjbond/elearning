defmodule KvApi.Animals.Animal do
  use Ecto.Schema
  import Ecto.Changeset

  schema "animals" do
    field :name, :string
    field :number_of_legs, :integer

    timestamps()
  end

  @doc false
  def changeset(animal, attrs) do
    animal
    |> cast(attrs, [:name, :number_of_legs])
    |> validate_required([:name, :number_of_legs])
  end
end
