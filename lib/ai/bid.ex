defmodule Euchre.Ai.Bid do
  alias Euchre.Trick

  def pick_up(hand, card, position) when length(hand) == 5 and is_integer(position) do
    %{hand: hand, card: card, position: position} |>
    dealer_picks_up_bauer |>
    pick_with_both_bauers |>
    just_pass
  end

  def dealer_picks_up_bauer(%{result: result}), do: %{result: result}
  def dealer_picks_up_bauer(%{position: 3, card: {_, "J"}}), do: %{result: :pick_up}
  def dealer_picks_up_bauer(data), do: data

  def pick_with_both_bauers(%{result: result}), do: %{result: result}
  def pick_with_both_bauers(data = %{hand: hand, card: {suit, _val}}) do
    bauers = Enum.filter(hand, fn (card) ->
      card == {suit, "J"} || card == {Trick.left_suit(suit), "J"}
    end)
    if length(bauers) == 2 do %{result: :pick_up} else data end
  end

  def just_pass(%{result: result}), do: result
  def just_pass(_), do: :pass
end
