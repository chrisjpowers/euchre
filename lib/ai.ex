defmodule Euchre.Ai do
  alias Euchre.Trick

  def choose_card(trump, played_cards, hand) do
    {lead_suit, _} = List.first(played_cards)
    Trick.lowest_card(hand, lead_suit, trump)
  end
end
