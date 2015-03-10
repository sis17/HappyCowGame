class GameCard < ActiveRecord::Base
  belongs_to :game, :foreign_key => "game_id"
  belongs_to :card, :foreign_key => "card_id"

  has_many :game_user_cards
  has_many :game_users, :through => :game_user_cards

  def as_json(options={})
    super(
      :include=> [
        :card,
        :game
      ]
    )
  end
end
