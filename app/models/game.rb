class Game < ActiveRecord::Base
  has_many :game_users
  has_many :users, through: :game_user

  has_many :rounds

  belongs_to :round
  belongs_to :round, :foreign_key => "round_id"

  has_many :ingredient_cats

  def as_json(options={})
    super(
      :include=> [
        {round: {:include => [:event, :game_user]}},
        :rounds,
        {game_users: {:include => [
          :user => {:only => [:name]}
        ]}}
      ]
    )
  end
end
