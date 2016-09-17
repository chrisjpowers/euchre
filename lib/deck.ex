defmodule Euchre.Deck do
  def generate do
    generate(suits, []) |>
    Enum.shuffle
  end

  defp generate([suit | suits_left], deck) do
    new_cards = Enum.map faces, fn (face) ->
      {face, suit}
    end
    generate(suits_left, deck ++ new_cards)
  end

  defp generate([], deck), do: deck

  def faces, do: ~w(9 10 J Q K A)
  def suits, do: ~w(clubs spades diamonds hearts)
end
