defmodule Euchre.Ai.Bid do
  alias Euchre.Trick
  alias Euchre.CardFilters

  def pick_up(hand, {suit, face}, position) when length(hand) == 5 and is_integer(position) do
    %{hand: hand, suit: suit, face: face, position: position} |>
    dealer_picks_up_bauer |>
    pick_with_both_bauers |>
    pick_with_right_and_two_littles |>
    just_pass
  end

  defp dealer_picks_up_bauer(res=%{result: _}), do: res
  defp dealer_picks_up_bauer(%{position: 3, face: "J"}), do: %{result: :pick_up}
  defp dealer_picks_up_bauer(data), do: data

  defp pick_with_both_bauers(res=%{result: _}), do: res
  defp pick_with_both_bauers(data = %{hand: hand, suit: suit}) do
    bauers = Enum.filter(hand, fn (card) ->
      card == {suit, "J"} || card == {Trick.left_suit(suit), "J"}
    end)
    if length(bauers) == 2 do %{result: :pick_up} else data end
  end

  defp pick_with_right_and_two_littles(res=%{result: _}), do: res
  defp pick_with_right_and_two_littles(data = %{hand: hand, suit: suit}) do
    hand |>
    CardFilters.trump_cards(suit) |>
    CardFilters.has_right_trump(suit) |>
    CardFilters.length_greater_than(2) |>
    CardFilters.if_present(%{result: :pick_up}, data)
  end

  defp just_pass(%{result: result}), do: result
  defp just_pass(_), do: :pass
end
