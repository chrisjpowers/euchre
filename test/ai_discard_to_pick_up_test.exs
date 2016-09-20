defmodule AiDiscardToPickUpTest do
  use ExUnit.Case
  alias Euchre.Ai.DiscardToPickUp
  alias Euchre.CardEncoding

  def discard(hand_codes, card_code) do
    hand = Enum.map hand_codes, &CardEncoding.code_to_card/1
    card = CardEncoding.code_to_card(card_code)
    discarded_card = DiscardToPickUp.discard(hand, card)
    CardEncoding.card_to_code(discarded_card)
  end

  def replace_card(hand_codes, card_code) do
    hand = Enum.map hand_codes, &CardEncoding.code_to_card/1
    card = CardEncoding.code_to_card(card_code)
    new_hand = DiscardToPickUp.replace_card(hand, card)
    new_hand_codes = Enum.map new_hand, &CardEncoding.card_to_code/1
    new_hand_codes
  end

  test "it discards a singleton" do
    assert discard(~w(9c 9d 10d 9s 10s), "Jh") == "9c"
  end

  test "discard a singleton that is not trump" do
    assert discard(~w(9h 9d 9c 10c Qc), "Jd") == "9h"
  end

  test "don't discard a singleton ace" do
    assert discard(~w(As 9h 9c 10c Qc), "Jd") == "9h"
  end

  test "don't discard singleton left bauer" do 
    assert discard(~w(Jd 9s 10s Js Qs), "9h") == "9s"
  end

  test "discard the lowest card if no singleton" do
    assert discard(~w(9s 10s Js 10c Jc), "Ah") == "9s"
  end

  test "replaces card in hand with picked up card" do
    assert replace_card(~w(9s 10s Js 10c Jc), "Ah") == ~w(Ah 10s Js 10c Jc)
  end
end
