class Game < ActiveRecord::Base
  has_many :game_users
  has_many :users, through: :game_user
  has_many :ingredient_cats
  has_many :rounds

  belongs_to :carddeck
  belongs_to :round
  belongs_to :round, :foreign_key => "round_id"
  belongs_to :cow

  has_many :ingredient_cats

  def as_json(options={})
    super(
      :include=> [
        {round: {:include => [:event,
          {game_user: {:include => [
            :user => {:only => [:id, :name, :experience]}
          ]}}
        ]}},
        :rounds,
        :carddeck,
        :cow,
        :ingredient_cats,
        {game_users: {:include => [
          :user => {:only => [:name]}
        ]}}
      ]
    )
  end
end
