class Move < ActiveRecord::Base
  belongs_to :game_user
  belongs_to :round
  belongs_to :ration

  def set_dice
    messages = []
    cow = self.round.game.cow
    # check if the ration is in the intestine (for constipation)
    # TODO - less or more dice for rumen pH
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
    self.save
    messages.push({title:'Ration Confirmed', text: 'The ration was selection was confirmed.', type:'success', time: 4})

    # -1 to all dice
    if cow.ph_marker <= 5.2
      messages.push({title:'Loss of Movement', text: 'The Ruemn pH is '+cow.ph_marker.to_s+', so all dice lose 1 value.', type:'warning', time: 0})
      self.dice1 -= 1
      self.dice2 -= 1
      self.dice3 -= 1
    end

    # use only the lowest dice if pH is greater than 7.4 or less than 5.6
    if cow.ph_marker >= 7.4 or cow.ph_marker <= 5.6
      messages.push({title:'Loss of Movement', text: 'The Ruemn pH is '+cow.ph_marker.to_s+', so you can only use the lowest dice.',
        type:'warning', time: 0})
      if self.dice1 > self.dice2
        if self.dice2 > self.dice3
          self.dice2 = 0
        else
          self.dice3 = 0
        end
        self.dice1 = 0
      elsif self.dice2 > self.dice3
        if self.dice1 > self.dice3
          self.dice1 = 0
        else
          self.dice3 = 0
        end
        self.dice2 = 0
      elsif self.dice3 > self.dice1
        if self.dice2 > self.dice3
          self.dice2 = 0
        else
          self.dice1 = 0
        end
        self.dice3 = 0
      end
    end
    self.save
    return messages
  end

  def select_dice(dieNum)
    messages = []
    # check for water, and diseases
    self.selected_die = dieNum
    self.save
    messages.push({title:'Dice Confirmed', message: 'The dice was selection was confirmed.', type:'success'})
    return messages
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
