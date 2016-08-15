defmodule Euchre.Trick do
  @value_precedence ~w{TOSS_OFF 9 10 J Q K A 9T 10T QT KT AT LEFT RIGHT}

  def winner(trump, cards) when length(cards) == 4 and is_nil(trump) == false do
    {lead_suit, _} = List.first(cards)
    Enum.max_by cards, fn (card) ->
      get_value(card, lead_suit, trump)
    end
  end

  defp get_value(card, lead_suit, trump) do
    new_value = value_with_bauers(card, lead_suit, trump)
    Enum.find_index(@value_precedence, &(&1 == new_value))
  end

  defp value_with_bauers(card, lead_suit, trump) do
    left = left_suit(trump)
    case card do
      {^trump, "J"} -> "RIGHT"
      {^left, "J"} -> "LEFT"
      {^trump, value} -> "#{value}T"
      {^lead_suit, value}  -> value
      {_, value}  -> "TOSS_OFF"
    end
  end

  defp left_suit("clubs"), do: "spades"
  defp left_suit("spades"), do: "clubs"
  defp left_suit("diamonds"), do: "hearts"
  defp left_suit("hearts"), do: "diamonds"
end
