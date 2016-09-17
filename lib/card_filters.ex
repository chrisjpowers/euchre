defmodule Euchre.CardFilters do
  alias Euchre.Trick

  def cards_matching_suit(hand, trump, lead_suit) do
    Enum.filter hand, fn (card) ->
      suit = get_suit_considering_bauers(card, trump)
      suit == lead_suit
    end
  end

  def partner_winning?(trump, cards) do
    winner = Trick.winner(trump, cards) 
    case length(cards) do
      2 -> winner == Enum.at(cards, 0)
      3 -> winner == Enum.at(cards, 1)
      _ -> false
    end
  end

  def trump_cards(cards, trump) do
    Enum.filter cards, fn ({suit, _value} = card) ->
      suit == trump || card == left_bauer(trump)
    end
  end

  def non_trump_cards(cards, trump) do
    Enum.reject cards, fn ({suit, _value} = card) ->
      suit == trump || card == left_bauer(trump)
    end
  end

  def aces(cards) do
    Enum.filter(cards, fn ({_suit, value}) -> value == "A" end)
  end

  def singletons(cards) do
    Enum.filter cards, fn({suit, _value}) ->
      Enum.count(cards, fn({s, _value}) -> s == suit end) == 1
    end
  end

  def lowest_card([], _lead_suit, _trump), do: nil
  def lowest_card(cards, lead_suit, trump) do
    Enum.min_by cards, fn (card) ->
      Trick.get_value(card, lead_suit, trump)
    end
  end

  def highest_card([], _lead_suit, _trump), do: nil
  def highest_card(cards, lead_suit, trump) do
    Enum.max_by cards, fn (card) ->
      Trick.get_value(card, lead_suit, trump)
    end
  end

  def blank_if(cards, fun) do
    if fun.(cards) do
      []
    else
      cards
    end
  end

  def get_suit_considering_bauers({suit, _}=card, trump) do
    if card == left_bauer(trump) do
      trump
    else
      suit
    end
  end

  def right_bauer(trump) do
    {trump, "J"}
  end

  def left_bauer(trump) do
    {Trick.left_suit(trump), "J"}
  end

  def remaining_trump(trump, sets) do
    played_cards = List.flatten sets
    [
      {trump, "J"}, left_bauer(trump), {trump, "A"}, {trump, "K"},
      {trump, "Q"}, {trump, "10"}, {trump, "9"}
    ] |>
    Enum.reject(fn (card) ->
      Enum.find(played_cards, fn (c) -> c == card end)
    end)
  end

  def has_right_bauer(cards, suit) do
    has_right = Enum.any?(cards, &(&1 == right_bauer(suit)))
    if has_right do cards else [] end
  end

  def has_left_bauer(cards, suit) do
    has_left = Enum.any?(cards, &(&1 == left_bauer(suit)))
    if has_left do cards else [] end
  end

  def has_bauer(cards, suit) do
    has_bauer = Enum.any? cards, fn(card) ->
      card == {suit, "J"} || card == left_bauer(suit)
    end
    if has_bauer do cards else [] end
  end

  def length_greater_than(cards, num) do
    if length(cards) > num do cards else [] end
  end

  def if_present(cards, true_val, false_val) do
    if length(cards) > 0 do true_val else false_val end
  end

  def is_present?(cards) do
    cards && length(cards) > 0
  end

  def has_off_ace(cards, suit) do
    cards
    |> non_trump_cards(suit)
    |> aces
    |> length_greater_than(0)
    |> if_present(cards, [])
  end
end
