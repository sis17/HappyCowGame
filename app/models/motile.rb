class Motile < ActiveRecord::Base
  belongs_to :game
  belongs_to :position

  def check_conflicts
    rations = Ration.joins(game_user:).where(position_id: self.position_id, game_user: {game: self.game_id})
  end

  def as_json(options={})
    super(
      :include => [
        :game,
        :position
      ]
    )
  end
end
