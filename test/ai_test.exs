defmodule AiTest do
  use ExUnit.Case

  alias Euchre.Ai

  def choose(trump_code, played_codes, hand_codes) do
    played_cards = Enum.map played_codes, &code_to_card/1
    hand = Enum.map hand_codes, &code_to_card/1
    result = Ai.choose_card(code_to_suit(trump_code), played_cards, hand)
    card_to_code(result)
  end

  def code_to_card(code) do
    [_, value, suit_code] = Regex.run(~r/^(.{1,2})(\w)$/, code) 
    {code_to_suit(suit_code), value}
  end

  def card_to_code({suit, value}) do
    "#{value}#{String.first suit}"
  end

  def code_to_suit("c"), do: "clubs"
  def code_to_suit("d"), do: "diamonds"
  def code_to_suit("h"), do: "hearts"
  def code_to_suit("s"), do: "spades"

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
end
