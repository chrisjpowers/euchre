defmodule Euchre.Ai.DiscardToPickUp do
  alias Euchre.Deck
  alias Euchre.CardFilters

  def discard(hand, card) do
    discard_non_ace_singleton(hand, card) ||
    discard_lowest_non_trump(hand, card)
  end

  defp discard_non_ace_singleton(hand, {trump, _}) do
    discard_non_ace_singleton(hand, non_trump_suits(trump), trump)
  end

  defp discard_non_ace_singleton(_hand, [], _trump), do: nil
  defp discard_non_ace_singleton(hand, [suit | suits], trump) do
    matches = CardFilters.cards_matching_suit(hand, trump, suit)
    card = if length(matches) == 1 do
      c = List.first(matches)
      if card_is_ace?(c) do nil else c end
    end
    card || discard_non_ace_singleton(hand, suits, trump)
  end

  defp discard_lowest_non_trump(hand, {trump, _}) do
    hand
    |> CardFilters.non_trump_cards(trump)
    |> CardFilters.lowest_card(trump, trump)
  end

  defp non_trump_suits(trump) do
    Deck.suits -- [trump]
  end

  defp card_is_ace?(card) do
    {_, face} = card
    face == "A"
  end
end
