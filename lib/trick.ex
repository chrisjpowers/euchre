defmodule Euchre.Trick do
  @non_trump_values ~w{9 10 J Q K A}
  @trump_values ~w{9 10 Q K A LEFT RIGHT}

  def winner(trump, cards) when length(cards) == 4 and is_nil(trump) == false do
    {lead_suit, _} = List.first(cards)
    cards |>
    follows_suit(lead_suit, trump) |>
    Enum.max_by fn (card) -> get_value(card, trump) end
  end

  defp follows_suit(cards, lead_suit, trump_suit) do
    Enum.filter cards, fn ({suit, value}) ->
      suit == lead_suit || suit == trump_suit
    end
  end

  defp get_value({suit, value}, trump) when suit != trump do
    Enum.find_index @non_trump_values, &(&1 == value)
  end

  defp get_value({suit, value} = card, trump) when suit == trump do
    new_value = value_with_bauers(card, trump)
    Enum.find_index(@trump_values, &(&1 == new_value)) + 10
  end

  defp value_with_bauers({suit, value}, trump) do
    case value do
      "J" -> "RIGHT"
      x -> x
    end
  end

  defp left_suit("clubs"), do: "spades"
  defp left_suit("spades"), do: "clubs"
  defp left_suit("diamonds"), do: "hearts"
  defp left_suit("hearts"), do: "diamonds"
end
