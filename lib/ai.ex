defmodule Euchre.Ai do
  alias Euchre.Trick

  def choose_card(trump, played_card_sets, hand, on_offense) do
    [played_cards | past_sets] = Enum.reverse(played_card_sets)
    if length(played_cards) > 0 do
      {lead_suit, _} = List.first(played_cards)
    end
    rules = [
      &offense_lead_with_right_bauer/5,
      &offense_lead_with_highest_remaining_trump/5,
      &offense_lead_with_high_trump_to_clear_bauers/5,
      &offense_lead_with_mid_trump_to_clear_right_bauer/5,
      &lead_with_off_ace/5,
      &lead_with_singleton_off_suit/5,
      &lead_with_lowest_off_suit/5,
      &play_winner_in_lead_suit/5,
      &throw_off_lowest_card_in_lead_suit/5,
      &play_trump_card/5,
      &throw_off_lowest_offsuit_card/5
    ]
    rules |>
      Enum.map(fn (rule) ->
        rule.(trump, lead_suit, played_card_sets, hand, on_offense)
      end) |>
      Enum.find &(&1)
  end

  defp offense_lead_with_right_bauer(trump, _lead_suit=nil, _played, hand, _on_offense=true) do
    right_bauer = {trump, "J"}
    if Enum.any?(hand, &(&1 == right_bauer)) do
      right_bauer
    end
  end
  defp offense_lead_with_right_bauer(_, _, _, _, _), do: nil

  defp offense_lead_with_highest_remaining_trump(trump, _lead_suit=nil, played_sets, hand, _on_offense=true) do
    played_cards = List.flatten played_sets
    all_trumps = [
      {trump, "J"}, left_bauer(trump), {trump, "A"}, {trump, "K"},
      {trump, "Q"}, {trump, "10"}, {trump, "9"}
    ]
    remaining_trump = Enum.reject(all_trumps, fn (card) ->
      Enum.find(played_cards, fn (c) -> c == card end)
    end)
    highest_remaining_trump = List.first remaining_trump
    Enum.find hand, fn (card) -> card == highest_remaining_trump end
  end
  defp offense_lead_with_highest_remaining_trump(_,_,_,_,_), do: nil

  def offense_lead_with_high_trump_to_clear_bauers(trump, _lead_suit=nil, _played, hand, _on_offense=true) do
    hand |>
    trump_cards(trump) |>
    blank_if(fn (cards) -> length(cards) < 3 end) |>
    highest_card(nil, trump)
  end
  def offense_lead_with_high_trump_to_clear_bauers(_, _, _, _, _), do: nil

  def offense_lead_with_mid_trump_to_clear_right_bauer(trump, _lead_suit=nil, _played, hand, _on_offense=true) do
    left = {Trick.left_suit(trump), "J"}
    trumps = trump_cards(hand, trump)
    has_left = !!Enum.find_index(trumps, fn (card) -> card == left end)
    if length(trumps) > 1 && has_left do
      trumps |>
      Enum.reject(fn (card) -> card == left end) |>
      highest_card(nil, trump)
    end
  end
  def offense_lead_with_mid_trump_to_clear_right_bauer(_, _, _, _, _), do: nil

  defp lead_with_off_ace(trump, nil, _played, hand, _) do
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
  defp lead_with_off_ace(_, _, _, _, _), do: nil

  defp lead_with_singleton_off_suit(trump, nil, _played, hand, _) do
    if length(trump_cards(hand, trump)) > 0 do
      hand |> non_trump_cards(trump) |> singletons |> List.first
    end
  end
  defp lead_with_singleton_off_suit(_, _, _, _, _), do: nil

  defp lead_with_lowest_off_suit(trump, lead_suit, _played, hand, _) do
    if !lead_suit do
      hand |> non_trump_cards(trump) |> lowest_card(nil, trump)
    end
  end

  defp play_winner_in_lead_suit(trump, lead_suit, played_sets, hand, _) do
    played = List.last(played_sets)
    cards_matching_suit(hand, trump, lead_suit) |>
    Enum.filter(fn (card) ->
      card == Trick.winner(trump, played ++ [card])
    end) |>
    Trick.lowest_card(lead_suit, trump) 
  end

  defp throw_off_lowest_card_in_lead_suit(trump, lead_suit, _played, hand, _) do
    cards_matching_suit(hand, trump, lead_suit) |> List.first
  end

  defp play_trump_card(_trump, nil, _played, _hand, _), do: nil
  defp play_trump_card(trump, lead_suit, played_sets, hand, _) do
    played = List.last played_sets
    if !partner_winning?(trump, played) do
      trump_cards(hand, trump) |>
      lowest_card(lead_suit, trump)
    end
  end

  defp throw_off_lowest_offsuit_card(trump, lead_suit, _played, hand, _) do
    Trick.lowest_card(hand, lead_suit, trump)
  end

  defp cards_matching_suit(hand, trump, lead_suit) do
    Enum.filter hand, fn ({suit, _value} = card) ->
      suit == lead_suit || card_is_left_bauer(trump, card)
    end
  end

  defp card_is_left_bauer(trump, card) do
    left_bauer(trump) == card
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
    Enum.filter cards, fn ({suit, _value} = card) ->
      suit == trump || card == {Trick.left_suit(trump), "J"}
    end
  end

  defp non_trump_cards(cards, trump) do
    Enum.reject cards, fn ({suit, _value} = card) ->
      suit == trump || card == {Trick.left_suit(trump), "J"}
    end
  end

  defp aces(cards) do
    Enum.filter(cards, fn ({_suit, value}) -> value == "A" end)
  end

  defp singletons(cards) do
    Enum.filter cards, fn({suit, _value}) ->
      Enum.count(cards, fn({s, _value}) -> s == suit end) == 1
    end
  end

  defp lowest_card([], _lead_suit, _trump), do: nil
  defp lowest_card(cards, lead_suit, trump) do
    Enum.min_by cards, fn (card) ->
      Trick.get_value(card, lead_suit, trump)
    end
  end

  defp highest_card([], _lead_suit, _trump), do: nil
  defp highest_card(cards, lead_suit, trump) do
    Enum.max_by cards, fn (card) ->
      Trick.get_value(card, lead_suit, trump)
    end
  end

  defp blank_if(cards, fun) do
    if fun.(cards) do
      []
    else
      cards
    end
  end

  defp left_bauer(trump) do
    {Trick.left_suit(trump), "J"}
  end
end
