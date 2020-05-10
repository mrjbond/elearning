defmodule Greeter do
  @moduledoc """
  Use this module to demonstrate the power of pattern-matching.
  """

  def greet("Alice" = name), do: "Hola, #{name}!"
  def greet("Bob"), do: "Hi there, Bobby Love!"
  def greet("John" <> _rest), do: "A true Johnny-on-the-spot!"
  def greet(name) when is_binary(name), do: "Hello, #{name}!"
end
