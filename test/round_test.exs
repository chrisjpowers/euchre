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

  def bid_pick_up(hand_codes, card_code, position) do
    hands = Enum.map hand_codes, fn (hand) ->
      Enum.map hand, &CardEncoding.code_to_card/1
    end
    card = CardEncoding.code_to_card(card_code)
    {new_hands, new_pos} = Round.bid_pick_up(hands, card, position)
    new_hand_codes = Enum.map new_hands, fn (hand) ->
      Enum.map hand, &CardEncoding.card_to_code/1
    end
    {new_hand_codes, new_pos}
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

  test "does a pick-up bidding round" do
    flipped_up_card = "Jh"
    hand1 = ~w(9d 10d Qd Kd Ad)
    hand2 = ~w(9c 10c Qc Kc Ac)
    hand3 = ~w(9s 10s Qs Ks As)
    # dealer will pick bauer, discard Js
    hands = [hand1, hand2, hand3, ~w(10h Qh Kh Ah Js)] 

    {new_hands, position} = bid_pick_up(hands, flipped_up_card, 0)
    assert position == 3 # dealer picked
    # Js was discarded, Jh added
    assert new_hands == [hand1, hand2, hand3, ~w(10h Qh Kh Ah Jh)]
  end

  test "does a pick-up bidding round starting at a non-zero position" do
    flipped_up_card = "Jh"
    hand1 = ~w(9d 10d Qd Kd Ad)
    hand2 = ~w(9c 10c Qc Kc Ac)
    hand3 = ~w(9s 10s Qs Ks As)
    # dealer will pick bauer, discard Js
    hands = [hand3, ~w(10h Qh Kh Ah Js), hand1, hand2] 

    {new_hands, position} = bid_pick_up(hands, flipped_up_card, 2)
    assert position == 1 # dealer picked
    # Js was discarded, Jh added
    assert new_hands == [hand3, ~w(10h Qh Kh Ah Jh), hand1, hand2]
  end

  test "pick_up bidding returns orig hands and nil bid position if no one bids" do
    flipped_up_card = "10h"
    hand1 = ~w(9c Jh Qs Kd Ac)
    hand2 = ~w(9d Jc Qh Ks Ad)
    hand3 = ~w(9s 10d Qc Kh As)
    hand4 = ~w(9h Js Qd Kc Ah)
    hands = [hand1, hand2, hand3, hand4] 

    {new_hands, position} = bid_pick_up(hands, flipped_up_card, 0)
    assert position == nil # no one picked
    assert new_hands == hands
  end
end
