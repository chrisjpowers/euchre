defmodule AiBidTest do
  use ExUnit.Case

  alias Euchre.Ai.Bid
  alias Euchre.CardEncoding

  def pick_up(hand_codes, face_up_code, position) do
    hand = Enum.map hand_codes, &CardEncoding.code_to_card/1
    face_up_card = CardEncoding.code_to_card(face_up_code)
    Bid.pick_up(hand, face_up_card, position)
  end

  def pick_up_with(hand_codes, face_up_code, position) do
    assert pick_up(hand_codes, face_up_code, position) == :pick_up
  end

  def pass_with(hand_codes, face_up_code, position) do
    assert pick_up(hand_codes, face_up_code, position) == :pass
  end

  test "it throws unless given five cards as a hand" do
    assert_raise FunctionClauseError, fn ->
      pick_up([], "9d", 0)
    end
  end

  test "it throws unless given a face up card" do
    assert_raise FunctionClauseError, fn ->
      pick_up(~w(9c 10c Jc Qc Kc), nil, 0)
    end
  end

  test "it throws unless given a position" do
    assert_raise FunctionClauseError, fn ->
      pick_up(~w(9c 10c Jc Qc Kc), "9d", nil)
    end
  end

  test "it returns :pass when a Jack is up and they are not dealer (position=3)" do
    pass_with(~w(Qc Kc Ac Js Jc), "Jh", 0)
    pass_with(~w(Qc Kc Ac Js Jc), "Jh", 1)
    pass_with(~w(Qc Kc Ac Js Jc), "Jh", 2)
  end
  
  # "Pass on a bauer, lose for an hour" -- not sure if we
  # keep this as a rule or not?
  test "returns :pick_up by dealer for a Jack" do
    pick_up_with(~w(Qc Kc Ac Js Jc), "Jh", 3)
  end

  test "pick up if both bauers" do
    pick_up_with(~w(Js Jc 9d 9h 9s), "Kc", 0)
  end

  test "pick up with the right and two littles" do
    pick_up_with(~w(Jc 9c 10c 9s 9d), "Kc", 0)
  end

  test "pick up with a bauer, a little, and an ace" do
    pick_up_with(~w(Js 9c Ad 9s 9d), "Kc", 0)
  end

  test "pick up with four trump" do
    pick_up_with(~w(9c 10c Qc Kc 9d), "Ac", 0)
  end
end
