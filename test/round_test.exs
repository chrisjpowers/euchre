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
  
  def score(trump_code, set_codes) do
    trump = CardEncoding.code_to_suit(trump_code)
    sets = Enum.map set_codes, fn(set) ->
      Enum.map set, &CardEncoding.code_to_card/1
    end
    Round.score(trump, sets)
  end

  test "plays a hand where first player wins all the tricks" do
    result = play_hand("c", [~w(Jc Js Ac Kc Qc), ~w(Ad Kd Qd Jd 10d), ~w(Ah Kh Qh Jh 10h), ~w(As Ks Qs 10s 9s)], 0)
    assert result == [~w(Jc 10d 10h 9s), ~w(Js Jd Jh 10s), ~w(Ac Qd Qh Qs), ~w(Kc Kd Kh Ks), ~w(Qc Ad Ah As)]
  end

  test "plays a hand where partner takes all the tricks" do
    result = play_hand("c", [~w(Ad Kd Qd Jd 10d), ~w(Ah Kh Qh Jh 10h), ~w(Jc Js Ac Kc Qc), ~w(As Ks Qs 10s 9s)], 0)
    assert result == [~w(Ad 10h Qc 9s), ~w(10d Jh Jc 10s), ~w(Jd Qh Js Qs), ~w(Qd Kh Ac Ks), ~w(Kd Ah Kc As)]
  end

  test "scores a point for team one when they got three tricks" do
    winners = [~w(Jc 9d 9h 9s), ~w(Js 10d 10h 10s), ~w(Ac Qd Qh Qs)]
    losers = [~w(Kd Ad Ks Kh), ~w(Jd Ah As Jh)]
    result = score("c", winners ++ losers)
    assert result == {1, 0}
  end

  test "scores a point for team one when they got four tricks" do
    winners = [~w(Jc 9d 9h 9s), ~w(Js 10d 10h 10s), ~w(Ac Qd Qh Qs), ~w(Ad Ks Kh Kd)]
    losers = [~w(Jh Ah As Jd)]
    result = score("c", winners ++ losers)
    assert result == {1, 0}
  end

  test "scores two points for team one when they got five tricks" do
    winners = [~w(Jc 9d 9h 9s), ~w(Js 10d 10h 10s), ~w(Ac Qd Qh Qs), ~w(Ad Ks Kh Kd), ~w(Ah Jh As Jd)]
    losers = []
    result = score("c", winners ++ losers)
    assert result == {2, 0}
  end

  test "scores a point for team two when they got three tricks" do
    seat_2_wins = [~w(9d Jc 9h 9s), ~w(10d Js 10h 10s), ~w(Qd Ac Qh Qs)]
    seat_1_wins = [~w(Ad Kd Ks Kh), ~w(Ah Jd As Jh)]
    result = score("c", seat_2_wins ++ seat_1_wins)
    assert result == {0, 1}
  end

  test "scores a point for team two when they got four tricks" do
    winners = [~w(9d Jc 9h 9s), ~w(10d Js 10h 10s), ~w(Qd Ac Qh Qs), ~w(Ks Ad Kh Kd)]
    losers = [~w(Ah Jh As Jd)]
    result = score("c", winners ++ losers)
    assert result == {0, 1}
  end

  test "scores two points for team two when they got five tricks" do
    winners = [~w(9d Jc 9h 9s), ~w(10d Js 10h 10s), ~w(Qd Ac Qh Qs), ~w(Ks Ad Kh Kd), ~w(Jh Ah As Jd)]
    losers = []
    result = score("c", winners ++ losers)
    assert result == {0, 2}
  end

  test "deals hands and remaining cards" do
    {[h1, h2, h3, h4], rem} = Round.deal_hands
    assert length(h1) == 5
    assert length(h2) == 5
    assert length(h3) == 5
    assert length(h4) == 5
    assert length(rem) == 4
    assert length(Enum.uniq(h1 ++ h2 ++ h3 ++ h4 ++ rem)) == 24
  end
end
