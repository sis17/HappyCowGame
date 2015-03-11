class GameUserCard < ActiveRecord::Base
  belongs_to :game_user
  belongs_to :game_card

  def use
    card = self.game_card.card
    success = false
    message = 'Default card message...'

    if card.title == 'Rumination'
      message = 'A random ration was moved back to the mouth.'
      game = self.game_user.game
#TODO - improve the randomness
      game_user_id = GameUser.where(game_id: game.id).first
      ration = Ration.where(game_user_id:game_user_id).first
      ration.position_id = 7
      ration.save

      game.cow.welfare += 1;
      game.cow.save
      success = true

    elsif card.title == 'Veterinarian'
      message = ''
      cow = self.game_user.game.cow
      disease = Event.where(id: cow.disease_id).first
      if disease
        message += ' '+disease.title+' has been removed.'
      end

      cow.disease_id = nil
      if cow.welfare < 0
        message += ' Welfare marker moved to 0.'
        cow.welfare = 0
      end
      cow.save
      success = true
    end

    if success
      self.destroy
      return {
        success: true,
        message: {title:'Card Used', text: message, type:'success'}
      }
    else
      return {
        success: false,
        message: {title:'Card Not Used', text: 'Sorry, the card could not be played, we`re still working on a condition for it.', type:'warning'}
      }
    end
  end

  def as_json(options={})
    super(
      :include=> [
        {game_card: {:include => [:card]}},
        {game_user: {:include => [:user  => {:only => [:id, :name, :experience]}]}}
      ]
    )
  end
end
