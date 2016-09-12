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
    trumps = CardFilters.trump_cards(hand, suit)
    has_right = Enum.any?(trumps, fn(card) ->
      card == {suit, "J"}
    end)
    if length(trumps) > 2 && has_right do
      %{result: :pick_up}
    else
      data
    end
  end

  defp just_pass(%{result: result}), do: result
  defp just_pass(_), do: :pass
end
