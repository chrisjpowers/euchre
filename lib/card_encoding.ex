defmodule Euchre.CardEncoding do
  def code_to_card(code) do
    [_, value, suit_code] = Regex.run(~r/^(.{1,2})(\w)$/, code) 
    {code_to_suit(suit_code), value}
  end

  def card_to_code({suit, value}) do
    "#{value}#{String.first suit}"
  end

  def code_to_suit("c"), do: "clubs"
  def code_to_suit("d"), do: "diamonds"
  def code_to_suit("h"), do: "hearts"
  def code_to_suit("s"), do: "spades"
end
