defmodule TrickTest do
  use ExUnit.Case

  alias Euchre.Trick
  alias Euchre.CardEncoding

  @cards [
    {"spades", "9"},
    {"hearts", "9"},
    {"clubs", "9"},
    {"diamonds", "9"}
  ]

  def winner(trump_code, card_codes) do
    cards = Enum.map card_codes, &CardEncoding.code_to_card/1
    trump = CardEncoding.code_to_suit(trump_code)
    result = Trick.winner(trump, cards)
    CardEncoding.card_to_code(result)
  end

  def lowest_card(card_codes, lead_code, trump_code) do
    cards = Enum.map card_codes, &CardEncoding.code_to_card/1
    trump = CardEncoding.code_to_suit(trump_code)
    lead_suit = CardEncoding.code_to_suit(lead_code)
    result = Trick.lowest_card(cards, lead_suit, trump)
    CardEncoding.card_to_code(result)
  end

  test "winner throws without a trump suit" do
    assert_raise FunctionClauseError, fn () ->
      winner(nil, ~w(9s 9h 9c 9d))
    end
  end

  test "returns the highest card if they are all the same suit" do
    assert winner("c", ~w(9s 10s Ks Qs)) == "Ks"
  end
  
  test "returns nil if passed an empty array" do
    assert Trick.winner("clubs", []) == nil
  end

  test "returns the highest card of the lead suit" do
    result = Trick.winner("clubs", [
      {"spades", "9"},
      {"spades", "10"},
      {"hearts", "K"},
      {"spades", "Q"}
    ])
    assert result == {"spades", "Q"}
    assert winner("c", ~w(9s 10s Kh Qs)) == "Qs"
  end

  test "returns a trump card" do
    assert winner("c", ~w(9s 10s 9c Qs)) == "9c"
  end

  test "right bauer beats A of trump" do
    assert winner("c", ~w(9s Ac Jc Qs)) == "Jc"
  end

  test "right bauer beats left bauer" do
    assert winner("c", ~w(9s Js Jc Qs)) == "Jc"
  end

  test "left bauer beats A of trump" do
    assert winner("c", ~w(9s Ac Js Qs)) == "Js"
  end

  test "left bauer beats A of that suit" do
    assert winner("c", ~w(9s As Js Qs)) == "Js"
  end

  test "lowest_card returns lowest of the off suit cards" do
    assert lowest_card(~w(10s 9d), "h", "c") == "9d"
  end
end
