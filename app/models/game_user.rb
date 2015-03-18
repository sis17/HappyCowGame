class GameUser < ActiveRecord::Base
  belongs_to :user, :foreign_key => "user_id"
  belongs_to :game, :foreign_key => "game_id"
  has_one :round

  has_many :game_user_cards
  has_many :game_cards, :through => :game_user_cards

  has_many :rations
  has_many :moves
  has_many :actions

  def as_json(options={})
    super(
      :include=> [
        {game: {:include => [
          {round: {:include => [
            {game_user: {:include => [:user  => {:only => [:id, :name]}]}}
          ]}},
          :cow,
          :game_users
        ]}},
        :rations,
        :game_cards,
        :user => {:only => [:name]}
      ]
    )
  end
end
