class Move < ActiveRecord::Base
  belongs_to :game_user
  belongs_to :round
  belongs_to :ration

  def set_dice
    messages = []
    cow = self.round.game.cow
    # check if the ration is in the intestine (for constipation)
    if cow.check_constipated and self.ration.position.area_id == 4
      messages.push({title:'Constipated Intestines', text: 'Your selected ration is in the intestines, so only the lowest dice can be used.', type:'warning', time: 0})
      self.dice1 = rand(1..3) # small movements
    elsif cow.check_diarrhea and self.ration.position.area_id == 4
      messages.push({title:'Diarrhea in the Intestines', text: 'Your selected ration is in the intestines, so only the highest dice can be used.', type:'warning', time: 0})
      self.dice1 = rand(5..6) # fast movements
    else
      self.dice1 = rand(1..6)
      self.dice2 = rand(1..6)
      self.add_water
    end

    # -1 to all dice
    if cow.ph_marker <= 5.2
      messages.push({title:'Loss of Movement', text: 'The Ruemn pH is '+cow.ph_marker.to_s+', so all dice lose 1 value.', type:'warning', time: 0})
      self.dice1 -= 1
      self.dice2 -= 1 if self.dice2
      self.dice3 -= 1 if self.dice3
    end

    # use only the lowest dice if pH is greater than 7.4 or less than 5.6
    if cow.ph_marker >= 7.4 or cow.ph_marker <= 5.6
      messages.push({title:'Loss of Movement', text: 'The Ruemn pH is '+cow.ph_marker.to_s+', so you can only use the lowest dice.',
        type:'warning', time: 0})
      if self.dice2
        self.dice1 = 0 if self.dice1 < self.dice2
        self.dice2 = 0 if self.dice2 < self.dice1
        if self.dice3
          self.dice3 = 0 if self.dice3 < self.dice2 or self.dice3 < self.dice1
          self.dice1 = 0 if self.dice1 < self.dice3
          self.dice2 = 0 if self.dice2 < self.dice3
        end
      end
    end
    self.save
    return messages
  end

  def get_movements
    movements = 0
    movements = self.dice1 if self.selected_die == 1
    movements = self.dice2 if self.selected_die == 2
    movements = self.dice3 if self.selected_die == 3

    if self.dice1 == self.dice2 and self.dice1 == self.dice3 # triple
      movements *= 3
    elsif movements == self.dice1 and movements == self.dice2 # first double
      movements *= 2
    elsif movements == self.dice1 and movements == self.dice3 # middle double
      movements *= 2
    elsif movements == self.dice2 and movements == self.dice3 # last double
      movements *= 2
    end

    return movements
  end

  def select_dice(dieNum)
    messages = []
    # check for water, and diseases
    self.selected_die = dieNum
    self.save

    if dieNum == 1 || dieNum == 2 || dieNum == 3
      self.movements_left = self.get_movements
      self.movements_made = 0
      self.save
    else
      messages.push({title:'Dice Unknown', text: 'The dice could not be found ('+dieNum.to_s+').', type:'warning', time:0})
    end

    messages.push({title:'Dice Confirmed', text: 'You have '+self.movements_left.to_s+' movements left.', type:'success', time:5})
    return messages
  end

  def confirm_move(position_id)
    messages = []
    success = false
    ration = self.ration
    new_position = Position.find(position_id)
    success = true if new_position

    # check the ration can move there
    game = self.round.game
    existing_motile = Motile.where(game: game, position_id: new_position.id).take
    existing_ration = Ration.joins(:game_user).where(game_users: {game_id:game.id}, position_id: new_position.id).take

    if existing_motile
      success = false
    elsif existing_ration and existing_ration.id != ration.id
      success = false
      # if incoming ration has more fiber, switch places
      if ration.count_type('fiber') > existing_ration.count_type('fiber')
        existing_ration.position = ration.position
        existing_ration.save
        success = true
        ration.game_user.score += 1
        ration.game_user.save
        messages.push({title:'Ration Pushed', text: 'You had more fiber than another ration, so pushed past it. +1pt.', type:'success', time: 5})
      else
        messages.push({title:'You Cannot Push', text: 'Your ration does not have enough fiber to push the other ration. You need at least '+(existing_ration.count_type('fiber')+1).to_s+' fiber.', type:'warning', time: 6})
      end
    end

    # update the move
    if success
      old_pos = ration.position
      ration.position = new_position
      ration.save
      self.movements_left -= 1
      self.movements_made += 1
      self.save

      #check if the ration is in the trough, to slide others down
      game.arrange_trough(old_pos)

      # consume the ration if on one of the meat, milk or muck squares
      if self.movements_left < 1 and (new_position.order == 78 or new_position.order == 86)
        messages.concat(game.finish_ration(ration))
      elsif new_position.order == 95
        messages.concat(game.finish_ration(ration)) # consume the ration if it's at the last position
      end
    end

    return {success: success, messages: messages}
  end

  def add_water
    if self.ration_id
      has_water = Ration.joins(ingredients: [:ingredient_cat] )
                      .where('ingredient_cats.name = "water" AND rations.id = ?', self.ration_id).first
      if has_water
        self.dice3 = rand(1..6)
      end
    end
  end

end
