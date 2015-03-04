class GameUserCard < ActiveRecord::Base
  belongs_to :game_user
  belongs_to :game_card
end
