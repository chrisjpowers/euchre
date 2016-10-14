defmodule Euchre.Ai.ChooseCard do
  import Euchre.CardFilters
  alias Euchre.Trick

  def choose_card(trump, played_card_sets, hand, on_offense) do
    [played_cards | _past_sets] = Enum.reverse(played_card_sets)
    leading_card = if length(played_cards) > 0 do
      List.first(played_cards)
    end
    lead_suit = if leading_card do
      get_suit_considering_bauers(leading_card, trump)
    end
    d = %{
      trump: trump,
      suit: lead_suit,
      sets: played_card_sets,
      hand: hand,
      on_offense: on_offense
    }
    offense_lead_with_right_bauer(d)
    || offense_lead_with_ace_if_you_have_last_trump(d)
    || offense_lead_with_highest_remaining_trump(d)
    || offense_lead_with_high_trump_to_clear_bauers(d)
    || offense_lead_with_mid_trump_to_clear_right_bauer(d)
    || lead_with_off_ace(d)
    || lead_with_singleton_off_suit(d)
    || lead_with_lowest_off_suit(d)
    || play_winner_in_lead_suit(d)
    || throw_off_lowest_card_in_lead_suit(d)
    || play_trump_card(d)
    || throw_off_lowest_offsuit_card(d)
  end

  defp offense_lead_with_right_bauer(%{trump: trump, hand: hand, suit: nil, on_offense: true}) do
    right_bauer = {trump, "J"}
    if Enum.any?(hand, &(&1 == right_bauer)) do
      right_bauer
    end
  end
  defp offense_lead_with_right_bauer(_), do: nil

  defp offense_lead_with_ace_if_you_have_last_trump(%{trump: trump, hand: hand, suit: nil, sets: played_sets, on_offense: true}) do
    remaining = remaining_trump(trump, played_sets)
    if Enum.sort(trump_cards(hand, trump)) == Enum.sort(remaining) do
      non_trump_cards(hand, trump) |>
      aces |>
      blank_if(fn (as) -> length(as) == 0 end) |>
      List.first
    end
  end
  defp offense_lead_with_ace_if_you_have_last_trump(_), do: nil

  defp offense_lead_with_highest_remaining_trump(%{trump: trump, hand: hand, suit: nil, on_offense: true, sets: played_sets}) do
    remaining = remaining_trump(trump, played_sets)
    highest_remaining_trump = List.first remaining
    Enum.find hand, fn (card) -> card == highest_remaining_trump end
  end
  defp offense_lead_with_highest_remaining_trump(_), do: nil

  def offense_lead_with_high_trump_to_clear_bauers(%{trump: trump, hand: hand, suit: nil, on_offense: true}) do
    hand |>
    trump_cards(trump) |>
    blank_if(fn (cards) -> length(cards) < 3 end) |>
    highest_card(nil, trump)
  end
  def offense_lead_with_high_trump_to_clear_bauers(_), do: nil

  def offense_lead_with_mid_trump_to_clear_right_bauer(%{trump: trump, hand: hand, suit: nil, on_offense: true}) do
    left = left_bauer(trump)
    trumps = trump_cards(hand, trump)
    has_left = left in trumps
    if length(trumps) > 1 && has_left do
      trumps |>
      Enum.reject(fn (card) -> card == left end) |>
      highest_card(nil, trump)
    end
  end
  def offense_lead_with_mid_trump_to_clear_right_bauer(_), do: nil

  defp lead_with_off_ace(%{trump: trump, hand: hand, suit: nil}) do
    non_trump_cards(hand, trump) |>
    aces |>
    Enum.sort_by(fn ({suit, _value}) ->
      left = Trick.left_suit(trump)
      left_penalty = if suit == left do 1 else 0 end
      length_penalty = Enum.count(hand, fn ({s, _value}) -> s == suit end) * 10
      length_penalty + left_penalty
    end) |>
    List.first
  end
  defp lead_with_off_ace(_), do: nil

  defp lead_with_singleton_off_suit(%{trump: trump, suit: nil, hand: hand}) do
    if length(trump_cards(hand, trump)) > 0 do
      hand |> non_trump_cards(trump) |> singletons |> List.first
    end
  end
  defp lead_with_singleton_off_suit(_), do: nil

  defp lead_with_lowest_off_suit(%{trump: trump, suit: nil, hand: hand}) do
    hand |> non_trump_cards(trump) |> lowest_card(nil, trump)
  end
  defp lead_with_lowest_off_suit(_), do: nil

  defp play_winner_in_lead_suit(%{trump: trump, suit: lead_suit, sets: played_sets, hand: hand}) do
    played = List.last(played_sets)
    cards_matching_suit(hand, trump, lead_suit) |>
    Enum.filter(&(&1 == Trick.winner(trump, played ++ [&1]))) |>
    Trick.lowest_card(lead_suit, trump)
  end

  defp throw_off_lowest_card_in_lead_suit(%{trump: trump, suit: lead_suit, hand: hand}) do
    cards_matching_suit(hand, trump, lead_suit) |> List.first
  end

  defp play_trump_card(%{trump: trump, suit: lead_suit, sets: played_sets, hand: hand}) when not is_nil(lead_suit) do
    played = List.last played_sets
    if !partner_winning?(trump, played) do
      trump_cards(hand, trump) |>
      lowest_card(lead_suit, trump)
    end
  end
  defp play_trump_card(_), do: nil

  defp throw_off_lowest_offsuit_card(%{trump: trump, suit: lead_suit, hand: hand}) do
    Trick.lowest_card(hand, lead_suit, trump)
  end
end
