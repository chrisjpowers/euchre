defmodule Euchre.Round do
  alias Euchre.Trick
  alias Euchre.Deck

  def play_hand(trump, hands, lead_position) do
    play_hand(trump, hands, lead_position, true, [])
  end

  defp play_hand(_, [[],[],[],[]], _, _, sets), do: sets
  defp play_hand(trump, hands, lead_position, on_offense, sets) do
    {set, remaining_hands} = play_trick(trump, hands, lead_position, on_offense, sets)
    new_lead_pos = winning_pos(trump, set)
    new_on_offense = winning_pos_on_offense(new_lead_pos, lead_position, on_offense)
    play_hand(trump, remaining_hands, new_lead_pos, new_on_offense, sets ++ [set])
  end

  # Wraps `Trick.play_trick` to handle shifting the hands based
  # on the lead position, since `Trick.play_trick` assumes that
  # the hand in the first index is the hand that will lead the trick.
  # This then unshifts the resulting output so that `Round` can
  # deal with the hands in absolute order.
  defp play_trick(trump, hands, lead_position, on_offense, sets) do
    offset_hands = add_offset(hands, lead_position)
    {offset_set, off_new_rem_hands} = Trick.play_trick(trump, offset_hands, on_offense, sets)
    new_rem_hands = remove_offset(off_new_rem_hands, lead_position)
    set = remove_offset(offset_set, lead_position)
    {set, new_rem_hands}
  end

  @doc """
  Given the trump and an array of sets (played tricks),
  this returns the number of points each team receives as a tuple,
  i.e. `{1, 0}` is one point for Team 1, `{0, 2}` is two points
  for Team 2.
  """
  def score(trump, sets) do
    score(trump, sets, 0, 0, 0)
  end

  defp score(_, [], _, 3, _), do: {1, 0}
  defp score(_, [], _, 4, _), do: {1, 0}
  defp score(_, [], _, 5, _), do: {2, 0}
  defp score(_, [], _, _, 3), do: {0, 1}
  defp score(_, [], _, _, 4), do: {0, 1}
  defp score(_, [], _, _, 5), do: {0, 2}
  defp score(trump, [set | sets], pos, team1_points, team2_points) do
    ordered_set = add_offset(set, pos)
    wp = winning_pos(trump, ordered_set)
    case rem(wp + pos, 4) do
      0 -> score(trump, sets, 0, team1_points + 1, team2_points)
      1 -> score(trump, sets, 1, team1_points, team2_points + 1)
      2 -> score(trump, sets, 2, team1_points + 1, team2_points)
      3 -> score(trump, sets, 3, team1_points, team2_points + 1)
    end
  end

  def deal_hands do
    deck = Deck.generate()
    hands_and_rem = Enum.chunk(deck, 5, 5, [])
    hands = Enum.slice(hands_and_rem, 0, 4)
    rem = List.last hands_and_rem
    {hands, rem}
  end

  defp add_offset(hands, 0), do: hands
  defp add_offset([first_hand | hands], lead_position) do
    add_offset(hands ++ [first_hand], lead_position - 1)
  end

  defp remove_offset(hands, 0), do: hands
  defp remove_offset(hands, lead_position) do
    front = Enum.slice(hands, 0, length(hands) - 1)
    last = List.last(hands)
    remove_offset([last | front], lead_position - 1)
  end

  defp winning_pos(trump, played_cards) do
    winning_card = Trick.winner(trump, played_cards)
    Enum.find_index played_cards, fn (card) -> card == winning_card end
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
