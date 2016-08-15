defmodule AiTest do
  use ExUnit.Case

  alias Euchre.Ai

  test "throws off lowest card when can't follow suit" do
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

  test "follows suit when one card that matches" do
    played_cards = [{"hearts", "A"}, {"hearts", "10"}, {"hearts", "J"}]
    hand = [
      {"diamonds", "9"},
      {"diamonds", "10"},
      {"diamonds", "J"},
      {"hearts", "Q"},
      {"diamonds", "K"}
    ]
    result = Ai.choose_card("clubs", played_cards, hand)
    assert result == {"hearts", "Q"}
  end

  test "takes the trick if it can with one of two cards" do
    played_cards = [{"hearts", "K"}, {"hearts", "10"}, {"hearts", "J"}]
    hand = [
      {"diamonds", "9"},
      {"diamonds", "10"},
      {"diamonds", "J"},
      {"hearts", "Q"},
      {"hearts", "A"}
    ]
    result = Ai.choose_card("clubs", played_cards, hand)
    assert result == {"hearts", "A"}
  end

  test "takes the trick with lowest card possible in last position" do
    played_cards = [{"hearts", "9"}, {"hearts", "10"}, {"hearts", "J"}]
    hand = [
      {"diamonds", "9"},
      {"diamonds", "10"},
      {"diamonds", "J"},
      {"hearts", "A"},
      {"hearts", "Q"}
    ]
    result = Ai.choose_card("clubs", played_cards, hand)
    assert result == {"hearts", "Q"}
  end
end
