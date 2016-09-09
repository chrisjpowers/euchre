defmodule TrickTest do
  use ExUnit.Case

  alias Euchre.Trick
  alias Euchre.CardEncoding

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

  def play_trick(trump_code, hand_codes, on_offense, past_set_codes \\ []) do
    trump = CardEncoding.code_to_suit(trump_code)
    hands = Enum.map hand_codes, fn (hand) ->
      Enum.map hand, &CardEncoding.code_to_card/1
    end
    past_sets = Enum.map past_set_codes, fn (codes) ->
      Enum.map codes, &CardEncoding.code_to_card/1
    end
    {played, new_hands} = Trick.play_trick(trump, hands, on_offense, past_sets)
    played_codes = Enum.map played, &CardEncoding.card_to_code/1
    new_hand_codes = Enum.map new_hands, fn (hand) ->
      Enum.map hand, &CardEncoding.card_to_code/1
    end
    {played_codes, new_hand_codes}
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

  test "lowest_card knows left bauer is higher than other trump" do
    assert lowest_card(~w(Qc Js), "h", "c") == "Qc"
  end

  # Playing a trick
  test "collects a card from each player, returns them in order" do
    result = play_trick("c", [~w(9c), ~w(10c), ~w(Qc), ~w(Kc)], false)
    assert result == {~w(9c 10c Qc Kc), [[], [], [], []]}
  end

  test "returns remaining hands" do
    result = play_trick("c", [~w(Ah 9c), ~w(9h 10c), ~w(10h Qc), ~w(Jh Kc)], false)
    assert result == {~w(Ah 9h 10h Jh), [~w(9c), ~w(10c), ~w(Qc), ~w(Kc)]}
  end

  test "takes a list of past sets of played cards" do
    # Because the Right Bauer was played on the first trick,
    # first position should lead with the Left Bauer (rather than
    # the off Ace). Without knowing past cards, they would lead Ace
    result = play_trick("c", [~w(Ah Js), ~w(9h 10d), ~w(Qc 10h), ~w(Jh Kc)], true, [~w(Jc 9c 10c Ac)])
    assert result == {~w(Js 9h Qc Kc), [~w(Ah), ~w(10d), ~w(10h), ~w(Jh)]}
  end
end
