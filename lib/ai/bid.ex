defmodule Euchre.Ai.Bid do
  alias Euchre.CardFilters

  def pick_up(hand, {suit, face}, position) when length(hand) == 5 and is_integer(position) do
    %{hand: hand, suit: suit, face: face, position: position}
    |> dealer_picks_up_bauer
    |> pick_with_both_bauers
    |> pick_with_right_and_two_littles
    |> pick_with_left_little_ace
    |> pick_with_many_littles
    |> just_pass
    |> Map.get(:result)
  end

  defp dealer_picks_up_bauer(res = %{result: _}), do: res
  defp dealer_picks_up_bauer(%{position: 3, face: "J"}), do: %{result: :pick_up}
  defp dealer_picks_up_bauer(data), do: data

  defp pick_with_both_bauers(res = %{result: _}), do: res
  defp pick_with_both_bauers(data = %{hand: hand, suit: suit}) do
    hand
    |> CardFilters.has_right_bauer(suit)
    |> CardFilters.has_left_bauer(suit)
    |> CardFilters.if_present(%{result: :pick_up}, data)
  end

  defp pick_with_right_and_two_littles(res = %{result: _}), do: res
  defp pick_with_right_and_two_littles(data = %{hand: hand, suit: suit}) do
    hand
    |> CardFilters.trump_cards(suit)
    |> CardFilters.has_right_bauer(suit)
    |> CardFilters.length_greater_than(2)
    |> CardFilters.if_present(%{result: :pick_up}, data)
  end

  defp pick_with_left_little_ace(res = %{result: _}), do: res
  defp pick_with_left_little_ace(data = %{hand: hand, suit: suit}) do
    hand
    |> CardFilters.has_bauer(suit)
    |> CardFilters.has_off_ace(suit)
    |> CardFilters.trump_cards(suit)
    |> CardFilters.length_greater_than(1)
    |> CardFilters.if_present(%{result: :pick_up}, data)
  end

  defp pick_with_many_littles(res = %{result: _}), do: res
  defp pick_with_many_littles(data = %{hand: hand, suit: suit}) do
    hand
    |> CardFilters.trump_cards(suit)
    |> CardFilters.length_greater_than(3)
    |> CardFilters.if_present(%{result: :pick_up}, data)
  end

  defp just_pass(res = %{result: _}), do: res
  defp just_pass(_), do: %{result: :pass}
end
