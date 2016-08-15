defmodule TrickTest do
  use ExUnit.Case

  alias Euchre.Trick

  @cards [
    {"spades", "9"},
    {"hearts", "9"},
    {"clubs", "9"},
    {"diamonds", "9"}
  ]

  test "winner throws with < 4 cards" do
    too_few = Enum.take(@cards, 3)
    assert_raise FunctionClauseError, fn () ->
      Trick.winner("clubs", too_few)
    end
  end

  test "winner throws without a trump suit" do
    assert_raise FunctionClauseError, fn () ->
      Trick.winner(nil, @cards)
    end
  end

  test "returns the highest card if they are all the same suit" do
    result = Trick.winner("clubs", [
      {"spades", "9"},
      {"spades", "10"},
      {"spades", "K"},
      {"spades", "Q"}
    ])
    assert result == {"spades", "K"}
  end

  test "returns the highest card of the lead suit" do
    result = Trick.winner("clubs", [
      {"spades", "9"},
      {"spades", "10"},
      {"hearts", "K"},
      {"spades", "Q"}
    ])
    assert result == {"spades", "Q"}
  end

  test "returns a trump card" do
    result = Trick.winner("clubs", [
      {"spades", "9"},
      {"spades", "10"},
      {"clubs", "9"},
      {"spades", "Q"}
    ])
    assert result == {"clubs", "9"}
  end

  test "right bauer beats A of trump" do
    result = Trick.winner("clubs", [
      {"spades", "9"},
      {"clubs", "A"},
      {"clubs", "J"},
      {"spades", "Q"}
    ])
    assert result == {"clubs", "J"}
  end

  test "right bauer beats left bauer" do
    result = Trick.winner("clubs", [
      {"spades", "9"},
      {"spades", "J"},
      {"clubs", "J"},
      {"spades", "Q"}
    ])
    assert result == {"clubs", "J"}
  end

  test "left bauer beats A of trump" do
    result = Trick.winner("clubs", [
      {"spades", "9"},
      {"clubs", "A"},
      {"spades", "J"},
      {"spades", "Q"}
    ])
    assert result == {"spades", "J"}
  end

  test "left bauer beats A of that suit" do
    result = Trick.winner("clubs", [
      {"spades", "9"},
      {"spades", "A"},
      {"spades", "J"},
      {"spades", "Q"}
    ])
    assert result == {"spades", "J"}
  end
end
