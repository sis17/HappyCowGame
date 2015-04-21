class GameUserCard < ActiveRecord::Base
  belongs_to :game_user
  belongs_to :game_card

  def use
    card = self.game_card.card
    if !card
      return {
        success: false,
        message: {title:'Card Not Used', text: 'The card has no type, an error has caused it to be redundant.', type:'danger', time: 6}
      }
    end
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
      game = self.game_user.game
      ration = nil
      rations = Ration.joins(:game_user, :position)
        .where(game_users: {game_id: self.game_user.game_id}, positions: {area_id:[2,3,4]}).all.shuffle[0..0]
      ration = rations[0] if rations.length > 0

      #puts 'rumination card use chosen ration with position: '+ration.position.order.to_s
      if ration
        ration.position = Position.where(order:7).take
        ration.save

        message = 'A ration belonging to '+ration.game_user.user.name
        message += ' with '+ration.describe_ingredients+' was moved back to the mouth.'
        game.cow.increase_welfare(1);
        message += ' Welfare increased to '+self.game_user.game.cow.welfare.to_s+'.'
        success = true
      else
        success = false
        message = "No ration was found in the digestive system to move."
      end

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
      message = 'The activists took up to 2 cards from all other players.'
      cow = self.game_user.game.cow
      cow.increase_welfare(3)
      message += 'The cow`s welfare increased to '+cow.welfare.to_s+'.'
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
      cow.set_oligos_marker(0) # reset the oligos marker, automatically resets points
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

    elsif card.uri == 'saponins'
      rations = Ration.joins(:game_user, :position).where(game_users: {game_id:self.game_user.game.id}, positions: {area_id:3})
      ration_count = 0
      rations.each do |ration|
        if ration.has_type('fiber')
          fiber_cat = IngredientCat.where(name: 'fiber', game: self.game_user.game).take
          protein_cat = IngredientCat.where(name: 'protien', game: self.game_user.game).take
          if fiber_cat
            ingredient = Ingredient.where(ration: ration, ingredient_cat: fiber_cat).take
            ingredient.ingredient_cat = protein_cat
            ingredient.save
            ration_count += 1
          end
        end
      end
      message = ration_count.to_s+' food rations had a fibre turned into a protien.'
      success = true

    elsif card.uri == 'bioreactor'
      message = 'All ingredients will gain an extra point when they become muck. '
      IngredientCat.where(game: self.game_user.game).each do |ing_cat|
        ing_cat.muck_score += 1
        ing_cat.save
      end
      success = true

    elsif card.uri == 'high_sugar_grass'
      message = ''
      rations = Ration.joins(:game_user).where(game_users: {game_id:self.game_user.game_id})
      ration_count = 0
      rations.each do |ration|
        if ration.position.area_id == 4 and ration.has_type('fiber')
          score = ration.count_type('fiber')
          ration.game_user.score += score
          ration.game_user.save
          ration_count += 1
          message += ration.game_user.user.name+' gained '+score.to_s+' points. '
        end
      end
      message = ration_count.to_s+' food rations had a fibre. '+message
      success = true

    elsif card.uri == 'thief'
      success = true
      rations = Ration.joins(:game_user).where(game_users: {game_id:self.game_user.game_id})
      if rations.length >= 1
        message = ''
        first = rations[0]
        last = rations[rations.length-1]
        first_ingredients = [] # this is a placeholder, for the transaction
        first.ingredients.each do |ing|
          first_ingredients.push(ing)
        end

        last.ingredients.each do |ing|
          ing.ration = first
          ing.save
        end

        first_ingredients.each do |ing|
          ing.ration = last
          ing.save
        end
        message += first.describe_ingredients+' have been moved to the first ration. '
        message += last.describe_ingredients+' have been moved to the last ration. '
      else
        message = 'There`s only one ration, so nothing was swapped.'
      end

    elsif card.category != 'action'
      return {
        success: false,
        message: {title:'Card Not Used', text: 'The card is not an action card, it must be added to a ration to be used.', type:'warning', time: 6}
      }
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
      action.set('Used a Card', " used the card #{card.title}, with the result: #{message}.",
        self.game_user.game.round.id, 2, self.game_user.id
      )
      self.destroy
      return {
        success: true,
        message: {title:'Card Used', text: message, type:'success', time: 8}
      }
    else
      return {
        success: false,
        message: {title:'Card Not Used', text: failed_text, type:'warning', time: 6}
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
