defmodule AiTest do
  use ExUnit.Case

  alias Euchre.Ai

  test "throws off lowest non-trump when can't follow suit" do
    played_cards = [{"hearts", "9"}, {"hearts", "10"}, {"hearts", "J"}]
    hand = [
      {"diamonds", "9"},
      {"diamonds", "10"},
      {"diamonds", "J"},
      {"diamonds", "Q"},
      {"diamonds", "K"}
    ]
    result = Ai.choose_card("clubs", played_cards, hand)
    assert result == {"diamonds", "9"}
  end
end
