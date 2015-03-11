class User < ActiveRecord::Base
  has_many :game_users
  has_many :games, through: :game_users

  has_many :rations
  has_many :rations, through: :game_users
  has_many :games

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
