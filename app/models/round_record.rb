class RoundRecord < ActiveRecord::Base
  belongs_to :round
  belongs_to :game_user
end
