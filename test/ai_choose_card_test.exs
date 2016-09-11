defmodule AiChooseCardTest do
  use ExUnit.Case

  alias Euchre.Ai.ChooseCard
  alias Euchre.CardEncoding

  def choose(trump_code, played_codes, hand_codes, on_offense \\ false) do
    played_codes = if !is_list(List.first(played_codes)) do
      [played_codes]
    else
      played_codes
    end
    played_cards = Enum.map played_codes, fn (set) ->
      Enum.map set, &CardEncoding.code_to_card/1
    end
    hand = Enum.map hand_codes, &CardEncoding.code_to_card/1
    trump = CardEncoding.code_to_suit(trump_code)
    result = ChooseCard.choose_card(trump, played_cards, hand, on_offense)
    CardEncoding.card_to_code(result)
  end

  test "throws off lowest card when can't follow suit" do
    assert choose("c", ~w(9h 10h Jh), ~w(9d 10d Jd Qd Kd)) == "9d"
  end

  test "follows suit when one card that matches" do
    assert choose("c", ~w(Ah 10h Jh), ~w(9d 10d Jd Qh Kd)) == "Qh"
  end

  test "takes the trick if it can with one of two cards" do
    assert choose("c", ~w(Kh 10h Jh), ~w(9d 10d Jd Qh Ah)) == "Ah"
  end

  test "takes the trick with lowest card possible in last position" do
    assert choose("c", ~w(9h 10h Jh), ~w(9d 10d Jd Ah Qh)) == "Qh"
  end

  test "must play left bauer to follow suit" do
    assert choose("h", ~w(9h 10h Jh), ~w(9d 10d Jd Ad Qd)) == "Jd"
  end

  test "don't play left if you have lower trump" do
    assert choose("c", ~w(9h 10h Jh), ~w(Jc Js Ac Kc 9c)) == "9c"
  end

  test "trump with the sole trump card if in last position" do
    assert choose("s", ~w(9h 10h Jh), ~w(Ks 10d Jd Ad Qd)) == "Ks"
  end

  test "trump with the lowest trump card if in last position" do
    assert choose("s", ~w(9h 10h Jh), ~w(As Ks Jd Ad Qd)) == "Ks"
  end

  test "trump with the left bauer before the right bauer" do
    assert choose("c", ~w(9h 10h Jh), ~w(Js Jc Jd Ad Qd)) == "Js"
  end

  test "do not trump your partner's good trick" do
    assert choose("c", ~w(9h Jh 10h), ~w(9d 9c Jd Ad Qd)) == "9d"
  end

  test "do not trump your partner's good trick when partner lead is winning" do
    assert choose("c", ~w(Ah 10h), ~w(9d 9c Jd Ad Qd)) == "9d"
  end

  test "play trump on your partner's good trick if you must follow suit" do
    assert choose("c", ~w(Jc 9c), ~w(9d 10c Jd Ad Qd)) == "10c"
  end

  test "must follow suit when left bauer is lead and you're in 3rd position" do
    assert choose("c", ~w(Js 9h), ~w(Qc 10h), false) == "Qc"
  end

  # Leading a trick

  test "lead with an off ace" do
    assert choose("c", ~w(), ~w(9d 10d Jd Qd Ah)) == "Ah"
  end

  test "lead with off ace over left ace when possible" do
    assert choose("c", ~w(), ~w(9d 10d Jd As Ah)) == "Ah"
  end

  test "lead with off ace with fewer cards in the suit" do
    assert choose("c", ~w(), ~w(9d 10d Jd Ad Ah)) == "Ah"
  end

  test "lead with left ace over off ace with more cards in the suit" do
    assert choose("c", ~w(), ~w(9h 10h Jd Ad As)) == "As"
  end

  test "lead with a singleton off suit if you have trump" do
    assert choose("c", ~w(), ~w(9c 9d 10d Jd 9h)) == "9h"
  end

  test "lead with lowest off suit card if no singletons" do
    assert choose("c", ~w(), ~w(Qs 9d 10d Jh Qh)) == "9d"
  end

  # When you are on offense

  test "lead with the right bauer if you lead on offense" do
    assert choose("c", ~w(), ~w(Ad Kd Qd Jd Jc), true) == "Jc"
  end

  test "lead with left bauer if you are on offense and have 3+ trump" do
    assert choose("c", ~w(), ~w(Kc Ac Js 9d 9h), true) == "Js"
  end

  test "do not lead with left bauer if it is your only trump" do
    assert choose("c", ~w(), ~w(9h Kh Ah Js 9d), true) == "Ah"
  end

  test "lead A trump if you have left bauer but right not played" do
    assert choose("c", ~w(), ~w(9h Kh Ac Js 9d), true) == "Ac"
  end

  test "lead the left bauer if the right bauer has been played" do
    assert choose("c", [~w(Jc 9c 10c Qc), ~w()], ~w(9h Kh Js 9d), true) == "Js"
  end

  test "lead an ace if you have the last trumps" do
    assert choose("c", [~w(Jc 9c 10c Qc), ~w()], ~w(Kc Ac Js Ah), true) == "Ah"
  end
end
