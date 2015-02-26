class GameCard < ActiveRecord::Base
  belongs_to :game, :foreign_key => "game_id"
  belongs_to :card, :foreign_key => "card_id"

  has_and_belongs_to_many :game_users
end
