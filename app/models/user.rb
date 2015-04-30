class User < ActiveRecord::Base
  has_many :game_users
  #has_many :games, through: :game_users

  has_many :rations
  has_many :rations, through: :game_users
  has_many :games

  def is_playing(game)
    game.game_users.each do |game_user|
      return true if game_user.user_id == self.id
    end
    return false
  end

  def as_json(options={})
    super(:only => [:name, :email, :experience, :id, :colour],
      :include=> [
        {game_users: {:include => [
          :game,
          :rations
        ]}}
      ]
    )
  end
end
