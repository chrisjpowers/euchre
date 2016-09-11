defmodule Euchre.Game do
  alias Euchre.Deck
  alias Euchre.Round

  def play do

  end

  defp play(lead_position, team1_score, team2_score) do

  end

  def deal_hands do
    deck = Deck.generate()
    hands_and_rem = Enum.chunk(deck, 5, 5, [])
    hands = Enum.slice(hands_and_rem, 0, 4)
    rem = List.last hands_and_rem
    {hands, rem}
  end
end
