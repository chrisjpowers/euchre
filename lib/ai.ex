defmodule Euchre.Ai do
  alias Euchre.Trick

  def choose_card(trump, played_cards, hand) do
    if length(played_cards) > 0 do
      {lead_suit, _} = List.first(played_cards)
    end
    rules = [
      &lead_with_off_ace/4,
      &lead_with_singleton_off_suit/4,
      &lead_with_lowest_off_suit/4,
      &play_winner_in_lead_suit/4,
      &throw_off_lowest_card_in_lead_suit/4,
      &play_trump_card/4,
      &throw_off_lowest_offsuit_card/4
    ]
    rules |>
      Enum.map(fn (rule) ->
        rule.(trump, lead_suit, played_cards, hand)
      end) |>
      Enum.find &(&1)
  end

  defp lead_with_off_ace(trump, lead_suit, _played, hand) do
    if !lead_suit do
      non_trump_cards(hand, trump) |>
      aces |>
      Enum.sort_by(fn ({suit, _value}) ->
        left = Trick.left_suit(trump)
        left_penalty = case suit do
          ^left -> 1
          _ -> 0
        end
        length_penalty = Enum.count(hand, fn ({s, _value}) -> s == suit end) * 10
        length_penalty + left_penalty
      end) |>
      List.first
    end
  end

  defp lead_with_singleton_off_suit(trump, lead_suit, _played, hand) do
    if !lead_suit do
      if length(trump_cards(hand, trump)) > 0 do
        hand |> non_trump_cards(trump) |> singletons |> List.first
      end
    end
  end

  defp lead_with_lowest_off_suit(trump, lead_suit, _played, hand) do
    if !lead_suit do
      hand |> non_trump_cards(trump) |> lowest_card(nil, trump)
    end
  end

  defp play_winner_in_lead_suit(trump, lead_suit, played, hand) do
    cards_matching_suit(hand, trump, lead_suit) |>
    Enum.filter(fn (card) ->
      card == Trick.winner(trump, played ++ [card])
    end) |>
    Trick.lowest_card(lead_suit, trump) 
  end

  defp throw_off_lowest_card_in_lead_suit(trump, lead_suit, _played, hand) do
    cards_matching_suit(hand, trump, lead_suit) |> List.first
  end

  defp play_trump_card(trump, lead_suit, played, hand) do
    if !partner_winning?(trump, played) do
      trump_cards(hand, trump) |>
      lowest_card(lead_suit, trump)
    end
  end

  defp throw_off_lowest_offsuit_card(trump, lead_suit, _played, hand) do
    Trick.lowest_card(hand, lead_suit, trump)
  end

  defp cards_matching_suit(hand, trump, lead_suit) do
    Enum.filter hand, fn ({suit, _value} = card) ->
      suit == lead_suit || card_is_left_bauer(trump, card)
    end
  end

  defp card_is_left_bauer(trump, {suit, value}) do
    Trick.left_suit(trump) == suit && value == "J"
  end

  defp partner_winning?(trump, cards) do
    winner = Trick.winner(trump, cards) 
    case length(cards) do
      2 -> winner == Enum.at(cards, 0)
      3 -> winner == Enum.at(cards, 1)
      _ -> false
    end
  end

  defp trump_cards(cards, trump) do
    Enum.filter(cards, fn ({suit, _value}) -> suit == trump end)
  end

  defp non_trump_cards(cards, trump) do
    Enum.reject(cards, fn ({suit, _value}) -> suit == trump end)
  end

  defp aces(cards) do
    Enum.filter(cards, fn ({_suit, value}) -> value == "A" end)
  end

  defp singletons(cards) do
    Enum.filter cards, fn({suit, _value}) ->
      Enum.count(cards, fn({s, _value}) -> s == suit end) == 1
    end
  end

  defp lowest_card(cards, lead_suit, trump) do
    if !Enum.empty?(cards) do
      Enum.min_by cards, fn (card) ->
        Trick.get_value(card, lead_suit, trump)
      end
    end
  end
end
