class Action < ActiveRecord::Base
  belongs_to :round
  belongs_to :game_user

  def set(title, description, round_id, phase, game_user_id)
    self.title = title
    self.description = description
    self.round_id = round_id
    self.phase = phase
    self.game_user_id = game_user_id
    self.save
  end
end
