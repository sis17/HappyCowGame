class Card < ActiveRecord::Base
  has_many :games
  has_many :games, through: :game_card

  has_many :game_cards

  has_many :games_users

  has_and_belongs_to_many :carddecks
end
