defmodule Euchre.Deck do
  @faces ~w(9 10 J Q K A)
  @suits ~w(clubs spades diamonds hearts)

  def generate do
    Enum.reduce @suits, [], fn (suit, cards) ->
      new_cards = Enum.map @faces, fn (face) ->
        {face, suit}
      end
      cards ++ new_cards
    end
  end

  def shuffle(deck) do
    Enum.shuffle deck
  end

  def deal(deck) do
    [first_card | rest] = deck
    {first_card, rest}
  end
end
