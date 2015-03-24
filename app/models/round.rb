class Round < ActiveRecord::Base
  belongs_to :event
  belongs_to :game_user, :class_name => "GameUser", foreign_key: "game_user_id"
  belongs_to :starting_user, :class_name => "GameUser", foreign_key: "starting_user_id"
  belongs_to :game

  has_many :moves
  has_many :actions

  def makeActive
    # cause the event to happen
    self.event.makeActive(self.game)
  end

  def as_json(options={})
    super(
      :include=> [
        :event,
        :moves,
        {game_user: {:include => [
          :user => {:only => [:name]}
        ]}}
      ]
    )
  end
end
