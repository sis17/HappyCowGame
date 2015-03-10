class GameUserCard < ActiveRecord::Base
  belongs_to :game_user
  belongs_to :game_card

  def as_json(options={})
    super(
      :include=> [
        {game_card: {:include => [:card]}},
        {game_user: {:include => [:user  => {:only => [:id, :name, :experience]}]}}
      ]
    )
  end
end
