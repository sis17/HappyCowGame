class CarddeckTest < ActiveSupport::TestCase
  test "that a card deck has a creator" do
    carddeck = carddecks(:basic)
    assert carddeck.user
  end

  test "that a card deck has a number of cards" do
    carddeck = carddecks(:basic)
    assert carddeck.cards
    assert_equal 19, carddeck.cards.length
  end
end
