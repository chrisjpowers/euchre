defmodule Euchre.Ai.Bid do
  alias Euchre.CardFilters
  alias Euchre.Deck

  def pick_up(hand, {suit, face}, position) when length(hand) == 5 and is_integer(position) do
    d = %{hand: hand, suit: suit, face: face, position: position}
    pick_up = dealer_picks_up_bauer(d)
    || pick_with_both_bauers(d)
    || pick_with_right_and_two_littles(d)
    || pick_with_left_little_ace(d)
    || pick_with_many_littles(d)
    if pick_up do :pick_up else :pass end
  end

  def choose_suit(hand, position) do
    choose_suit(hand, position, Deck.suits)
  end

  defp choose_suit(_hand, _position, []), do: :pass
  defp choose_suit(hand, position, [suit | suits]) do
    case pick_up(hand, {suit, "9"}, position) do
      :pick_up -> suit
      :pass -> choose_suit(hand, position, suits)
    end
  end

  defp dealer_picks_up_bauer(%{position: 3, face: "J"}), do: true
  defp dealer_picks_up_bauer(_), do: false

  defp pick_with_both_bauers(%{hand: hand, suit: suit}) do
    hand
    |> CardFilters.has_right_bauer(suit)
    |> CardFilters.has_left_bauer(suit)
    |> CardFilters.is_present?
  end

  defp pick_with_right_and_two_littles(%{hand: hand, suit: suit}) do
    hand
    |> CardFilters.trump_cards(suit)
    |> CardFilters.has_right_bauer(suit)
    |> CardFilters.length_greater_than(2)
    |> CardFilters.is_present?
  end

  defp pick_with_left_little_ace(%{hand: hand, suit: suit}) do
    hand
    |> CardFilters.has_bauer(suit)
    |> CardFilters.has_off_ace(suit)
    |> CardFilters.trump_cards(suit)
    |> CardFilters.length_greater_than(1)
    |> CardFilters.is_present?
  end

  defp pick_with_many_littles(%{hand: hand, suit: suit}) do
    hand
    |> CardFilters.trump_cards(suit)
    |> CardFilters.length_greater_than(3)
    |> CardFilters.is_present?
  end
end
