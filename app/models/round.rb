class Round < ActiveRecord::Base
  belongs_to :event
  belongs_to :game_user
  has_many :moves
end
