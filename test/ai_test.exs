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

  test "must play left bauer to follow suit" do
    played_cards = [{"hearts", "9"}, {"hearts", "10"}, {"hearts", "J"}]
    hand = [
      {"diamonds", "9"},
      {"diamonds", "10"},
      {"diamonds", "J"},
      {"diamonds", "A"},
      {"diamonds", "Q"}
    ]
    result = Ai.choose_card("hearts", played_cards, hand)
    assert result == {"diamonds", "J"}
  end

  test "trump with the sole trump card if in last position" do
    played_cards = [{"hearts", "9"}, {"hearts", "10"}, {"hearts", "J"}]
    hand = [
      {"spades", "K"},
      {"diamonds", "10"},
      {"diamonds", "J"},
      {"diamonds", "A"},
      {"diamonds", "Q"}
    ]
    result = Ai.choose_card("spades", played_cards, hand)
    assert result == {"spades", "K"}
  end

  test "trump with the lowest trump card if in last position" do
    played_cards = [{"hearts", "9"}, {"hearts", "10"}, {"hearts", "J"}]
    hand = [
      {"spades", "A"},
      {"spades", "K"},
      {"diamonds", "J"},
      {"diamonds", "A"},
      {"diamonds", "Q"}
    ]
    result = Ai.choose_card("spades", played_cards, hand)
    assert result == {"spades", "K"}
  end

  test "trump with the left bauer before the right bauer" do
    played_cards = [{"hearts", "9"}, {"hearts", "10"}, {"hearts", "J"}]
    hand = [
      {"spades", "J"},
      {"clubs", "J"},
      {"diamonds", "J"},
      {"diamonds", "A"},
      {"diamonds", "Q"}
    ]
    result = Ai.choose_card("clubs", played_cards, hand)
    assert result == {"spades", "J"}
  end

  test "do not trump your partner's good trick" do
    played_cards = [{"hearts", "9"}, {"hearts", "J"}, {"hearts", "10"}]
    hand = [
      {"diamonds", "9"},
      {"clubs", "9"},
      {"diamonds", "J"},
      {"diamonds", "A"},
      {"diamonds", "Q"}
    ]
    result = Ai.choose_card("clubs", played_cards, hand)
    assert result == {"diamonds", "9"}
  end

  test "do not trump your partner's good trick when partner lead is winning" do
    played_cards = [{"hearts", "A"}, {"hearts", "10"}]
    hand = [
      {"diamonds", "9"},
      {"clubs", "9"},
      {"diamonds", "J"},
      {"diamonds", "A"},
      {"diamonds", "Q"}
    ]
    result = Ai.choose_card("clubs", played_cards, hand)
    assert result == {"diamonds", "9"}
  end
end
