defmodule RoundTest do
  use ExUnit.Case

  alias Euchre.Round
  alias Euchre.CardEncoding

  def play_hand(trump_code, hand_codes, lead_position) do
    trump = CardEncoding.code_to_suit(trump_code)
    hands = Enum.map hand_codes, fn (hand) ->
      Enum.map hand, &CardEncoding.code_to_card/1
    end
    sets = Round.play_hand(trump, hands, lead_position)
    set_codes = Enum.map sets, fn (set) ->
      Enum.map set, &CardEncoding.card_to_code/1
    end
    set_codes
  end

  test "plays a hand where first player wins all the tricks" do
    result = play_hand("c", [~w(Jc Js Ac Kc Qc), ~w(Ad Kd Qd Jd 10d), ~w(Ah Kh Qh Jh 10h), ~w(As Ks Qs 10s 9s)], 0)
    assert result == [~w(Jc 10d 10h 9s), ~w(Js Jd Jh 10s), ~w(Ac Qd Qh Qs), ~w(Kc Kd Kh Ks), ~w(Qc Ad Ah As)]
  end

  test "plays a hand where partner takes all the tricks" do
    result = play_hand("c", [~w(Ad Kd Qd Jd 10d), ~w(Ah Kh Qh Jh 10h), ~w(Jc Js Ac Kc Qc), ~w(As Ks Qs 10s 9s)], 0)
    assert result == [~w(Ad 10h Qc 9s), ~w(10d Jh Jc 10s), ~w(Jd Qh Js Qs), ~w(Qd Kh Ac Ks), ~w(Kd Ah Kc As)]
  end
end
