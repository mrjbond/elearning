defmodule KvApi.Repo.Migrations.CreateAnimals do
  use Ecto.Migration

  def change do
    create table(:animals) do
      add :name, :string
      add :number_of_legs, :integer

      timestamps()
    end
  end
end
