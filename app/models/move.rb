class Move < ActiveRecord::Base
  belongs_to :game_user
  belongs_to :round
  belongs_to :ration
end
