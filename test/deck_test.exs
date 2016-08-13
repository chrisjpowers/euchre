defmodule DeckTest do
  use ExUnit.Case

  alias Euchre.Deck

  test "has 24 cards" do
    deck = Deck.generate()
    assert length(deck) == 24
  end

  test "shuffles a deck" do
    deck = Deck.generate()
    shuffled = Deck.shuffle(deck)
    assert length(deck) == length(shuffled)
    assert shuffled != deck
  end

  test "deals a card" do
    deck = [{"hearts", "9"}, {"spades", "9"}]
    {dealt_card, new_deck} = Deck.deal(deck)
    assert dealt_card == {"hearts", "9"}
    assert new_deck == [{"spades", "9"}]
  end
end
