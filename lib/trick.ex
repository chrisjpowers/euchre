defmodule Euchre.Trick do
  alias Euchre.Ai.ChooseCard

  @value_precedence ~w{9O 10O JO QO KO AO 9 10 J Q K A 9T 10T QT KT AT LEFT RIGHT}

  def winner(trump, cards) when is_list(cards) and is_nil(trump) == false do
    if length(cards) > 0 do
      {lead_suit, _} = List.first(cards)
      Enum.max_by cards, &(get_value(&1, lead_suit, trump))
    end
  end

  def lowest_card(cards, lead_suit, trump) do
    if !Enum.empty?(cards) do
      Enum.min_by cards, &(get_value(&1, lead_suit, trump))
    end
  end

  def left_suit("clubs"), do: "spades"
  def left_suit("spades"), do: "clubs"
  def left_suit("diamonds"), do: "hearts"
  def left_suit("hearts"), do: "diamonds"

  def get_value(card, lead_suit, trump) do
    new_value = value_with_bauers(card, lead_suit, trump)
    Enum.find_index(@value_precedence, &(&1 == new_value))
  end

  def play_trick(trump, hands, on_offense, past_sets) do
    Enum.reduce((0..3), {[], [nil, nil, nil, nil]}, fn (x, memo) ->
      {played_cards, remaining_hands} = memo
      pos = rem(x, 4)
      hand = Enum.at(hands, pos)
      card = ChooseCard.choose_card(trump, past_sets ++ [played_cards], hand, on_offense)
      new_hand = Enum.reject hand, fn (c) -> card == c end
      new_remaining = List.replace_at remaining_hands, pos, new_hand
      {played_cards ++ [card], new_remaining}
    end)
  end

  defp value_with_bauers(card, lead_suit, trump) do
    left = left_suit(trump)
    case card do
      {^trump, "J"} -> "RIGHT"
      {^left, "J"} -> "LEFT"
      {^trump, value} -> "#{value}T"
      {^lead_suit, value}  -> value
      {_, value}  -> "#{value}O"
    end
  end
end
