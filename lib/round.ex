defmodule Euchre.Round do
  alias Euchre.Trick

  def play_hand(trump, hands, lead_position) do
    play_hand(trump, hands, lead_position, true, [])
  end

  defp play_hand(_, [[],[],[],[]], _, _, sets), do: sets
  defp play_hand(trump, hands, lead_position, on_offense, sets) do
    {set, new_rem_hands} = Trick.play_trick(trump, hands, lead_position, on_offense, sets)
    new_lead_pos = winning_pos(trump, set, lead_position)
    new_on_offense = winning_pos_on_offense(new_lead_pos, lead_position, on_offense)
    play_hand(trump, new_rem_hands, new_lead_pos, new_on_offense, sets ++ [set])
  end

  defp winning_pos(trump, played_cards, lead_position) do
    winning_card = Trick.winner(trump, played_cards)
    winning_index = Enum.find_index played_cards, fn (card) -> card == winning_card end
    rem(winning_index + lead_position, 4)
  end

  defp winning_pos_on_offense(new_pos, old_pos, old_on_offense) do
    # If the positions are both odd or both even, these positions are
    # partners and will have the same offense/defense state. Otherwise,
    # use the opposite value.
    if rem(new_pos, 2) == rem(old_pos, 2) do
      old_on_offense
    else
      !old_on_offense
    end
  end
end
