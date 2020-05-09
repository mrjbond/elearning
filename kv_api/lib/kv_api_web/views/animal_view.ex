defmodule KvApiWeb.AnimalView do
  use KvApiWeb, :view
  alias KvApiWeb.AnimalView

  def render("index.json", %{animals: animals}) do
    %{data: render_many(animals, AnimalView, "animal.json")}
  end

  def render("show.json", %{animal: animal}) do
    %{data: render_one(animal, AnimalView, "animal.json")}
  end

  def render("animal.json", %{animal: animal}) do
    %{id: animal.id, name: animal.name, number_of_legs: animal.number_of_legs}
  end
end
