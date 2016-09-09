defmodule DeckTest do
  use ExUnit.Case

  alias Euchre.Deck

  test "has 24 cards" do
    deck = Deck.generate()
    assert length(deck) == 24
  end

  test "shuffles a deck" do
    deck1 = Deck.generate()
    deck2 = Deck.generate()
    assert deck1 != deck2
  end
end
