class GameUser < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_id"
  belongs_to :game, :foreign_key => "game_id"
  has_one :round

  has_and_belongs_to_many :game_cards

  has_many :rations
  has_many :moves
end
