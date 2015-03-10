class Event < ActiveRecord::Base
  has_one :round

  def makeActive
    game = self.round.game
    #game.reset_ingredient_values

    # 3 cateogries that 'stick'
    if self.category == 'disease'
      game.cow.disease_id = self.id
    end
    if self.category == 'weather'
      game.cow.weather_id = self.id
    end
    if self.category == 'pregnancy'
      game.cow.pregnancy_id = if game.cow.pregnancy_id then nil else self.id end
    end
    game.cow.save

    # when the event begins
    if self.title == 'Constipation'
      game.cow.welfare -= 1
      game.cow.save
    end
  end

  #def makeInactive
    # when the event is finished
  #end
end
