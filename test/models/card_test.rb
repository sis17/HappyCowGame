require 'test_helper'

class CardTest < ActiveSupport::TestCase
  test "that a card has a creator" do
    card = cards(:card_energy)
    assert card.user
  end
end
