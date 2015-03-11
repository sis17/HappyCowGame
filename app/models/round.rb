class Round < ActiveRecord::Base
  belongs_to :event
  belongs_to :game_user
  belongs_to :game
  has_many :moves

  def makeActive
    # cause the event to happen
    self.event.makeActive
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