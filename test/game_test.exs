defmodule GameTest do
  use ExUnit.Case

  alias Euchre.Game

  test "plays a game and returns the final score" do
    {team1_score, team2_score} = Game.play()
    assert (team1_score == 10) || (team2_score == 10)
  end

  test "deals hands and remaining cards" do
    all = Game.deal_hands
    {[h1, h2, h3, h4], rem} = all
    assert length(h1) == 5
    assert length(h2) == 5
    assert length(h3) == 5
    assert length(h4) == 5
    IO.puts inspect(rem)
    assert length(rem) == 4
  end
end
