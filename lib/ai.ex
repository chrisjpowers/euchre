defmodule Euchre.Ai do
  alias Euchre.Trick

  def choose_card(trump, played_cards, hand) do
    {lead_suit, _} = List.first(played_cards)
    rules = [
      &play_winner_in_lead_suit/4,
      &throw_off_lowest_card/4,
      &throw_off_lowest_offsuit_card/4
    ]
    rules |>
      Enum.map(fn (rule) ->
        rule.(trump, lead_suit, played_cards, hand)
      end) |>
      Enum.find &(&1)
  end

  defp play_winner_in_lead_suit(trump, lead_suit, played, hand) do
    cards = cards_matching_suit(hand, lead_suit)
    winners = Enum.filter(cards, fn (card) ->
      card == Trick.winner(trump, played ++ [card])
    end)
    if length(winners) > 0 do
      Trick.lowest_card(winners, lead_suit, trump) 
    end
  end

  defp throw_off_lowest_card(trump, lead_suit, _played, hand) do
    cards = cards_matching_suit(hand, lead_suit)
    List.first(cards)
  end

  defp throw_off_lowest_offsuit_card(trump, lead_suit, _played, hand) do
    Trick.lowest_card(hand, lead_suit, trump)
  end

  defp cards_matching_suit(hand, lead_suit) do
    Enum.filter hand, fn ({suit, _}) -> suit == lead_suit end
  end
end
