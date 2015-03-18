class GameUserCard < ActiveRecord::Base
  belongs_to :game_user
  belongs_to :game_card

  def use
    card = self.game_card.card
    success = false
    message = 'Default card message...'
    failed_text = 'Sorry, the card could not be played, we`re still working on a condition for it.'

    # up the rumen ph by 1.5
    if card.uri == 'acidodis_plus'
      ph_marker = self.game_user.game.cow.increase_ph_marker(3)
      message = "The PH in the cow`s rumen increased to #{ph_marker}."
      success = true
    elsif card.uri == 'acidodis_minus'
      ph_marker = self.game_user.game.cow.decrease_ph_marker(3)
      message = "The PH in the cow`s rumen decreased to #{ph_marker}."
      success = true

    elsif card.uri == 'rumination'
      message = 'A random ration was moved back to the mouth.'
      game = self.game_user.game
#TODO - improve the randomness
      game_user_id = GameUser.where(game_id: game.id).first
      ration = Ration.where(game_user_id:game_user_id).first
      ration.position_id = 7
      ration.save

      game.cow.increase_welfare(1);
      success = true

    elsif card.uri == 'vet'
      message = ''
      cow = self.game_user.game.cow
      disease = Event.where(id: cow.disease_id).first
      if disease
        disease.makeInactive(self.game_user.game)
        message += ' '+disease.title+' has been removed.'
      end

      cow.disease_id = nil
      if cow.welfare < 0
        message += ' Welfare marker moved to 0.'
        cow.set_welfare(0)
      end
      cow.save
      success = true

    # move the muck marker to 0, and give the player that many points
    elsif card.uri == 'clean_stables'
      message = 'The muck marker has been set back to 0,'
      cow = self.game_user.game.cow
      self.game_user.score += cow.muck_marker
      message += " and you got #{cow.muck_marker} points."
      self.game_user.save
      cow.muck_marker = 0
      cow.save
      success = true

    # welfare +3, all other players lose 2 cards
    elsif card.uri == 'activists'
      message = 'The activists took 2 cards from all other players. The cow`s welfare is at 0.'
      cow = self.game_user.game.cow
      cow.increase_welfare(3)
      self.game_user.game.game_users.each do |game_user|
        if game_user.id != self.game_user.id
          count = 2
          game_user.game_user_cards.each do |game_user_card|
            if count > 0
              count -= 1
              game_user_card.destroy
            end
          end
        end
      end
      success = true

    # the oligos marker moves to 0, if already there -1 welfare
    elsif card.uri == 'deficiency'
      message = 'The cow`s oligos marker has been set to 0. '
      cow = self.game_user.game.cow
      if cow.oligos_marker == 0
        cow.decrease_welfare(1)
        message += 'The cow had no previous oligos, so it`s welfare decreased.'
      end
      cow.oligos_marker = 0
      cow.save

      success = true

      # set welfare to 0, remove disease. costs 4 cards. (4 points)
    elsif card.uri == 'medical_insurance'
      if self.game_user.game_user_cards.length > 4
        message = 'The cow`s welfare is now at 0.'
        cow = self.game_user.game.cow
        cow.set_welfare(0)
        if cow.disease_id
          event = Event.where(id: cow.disease_id).first
          if event
            event.makeInactive(self.game_user.game)
          end
          message += " The disease #{event.title} has been removed."
          cow.disease_id = nil
        end
        cow.save
        count = 4
        self.game_user.game_user_cards do |game_user_card|
          if game_user_card.id != self.id and count > 0
            count += 1
            game_user_card.destroy
          end
        end
        success = true
      else
        failed_text = 'You cannot use Medical Insurance, as you do not have 4 cards to spend.'
        success = false
      end

    elsif card.uri == 'probiotics'
      message = "The cow`s welfare has increased, and the Rumen PH is reset to 6.5"
      self.game_user.game.cow.set_ph_marker(6.5)
      self.game_user.game.cow.increase_welfare(1)
      success = true

    elsif card.uri == 'farm_improvements'
      message = "There was no weather event to cancel."
      cow = self.game_user.game.cow
      event = Event.where(id: cow.weather_id).first
      if event
        event.makeInactive(self.game_user.game)
        cow.weather_id = nil
        cow.save
        message = "The weather event #{event.title} has been cancelled."
      end
      success = true
    end

    if success
      #award the card points
      if card.points > 0
        message += " You gained #{card.points} points. "
        self.game_user.score += card.points
        self.game_user.save
      end
      #record the action
      action = Action.new
      action.set('Used a Card', "They used the card #{card.title}, with the result: #{message}.",
        self.game_user.game.round.id, 2, self.game_user.id
      )
      self.destroy
      return {
        success: true,
        message: {title:'Card Used', text: message, type:'success'}
      }
    else
      return {
        success: false,
        message: {title:'Card Not Used', text: failed_text, type:'warning'}
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
