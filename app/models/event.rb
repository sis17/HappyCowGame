class Event < ActiveRecord::Base
  has_one :round

  def makeActive
    game = self.round.game
    cow = self.round.game.cow
    #game.reset_ingredient_values

    # 3 cateogries that 'stick'
    if self.category == 'disease'
      existing_event = Event.where(id: cow.disease_id).first
      if existing_event
        existing_event.makeInactive(game)
      end
      cow.disease_id = self.id
    end
    if self.category == 'weather'
      existing_event = Event.where(id: cow.weather_id).first
      if existing_event
        existing_event.makeInactive(game)
      end
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
    elsif self.title == 'Diarrhea'
      game.cow.welfare -= 1
      game.cow.save
    elsif self.title == 'Cold Weather'
      ingredient_cats = game.ingredient_cats
      ingredient_cats.each do |ingredient_cat|
        ingredient_cat.milk_score -= 1
        ingredient_cat.meat_score -= 1
        ingredient_cat.muck_score -= 1
        ingredient_cat.save
      end
    elsif self.title == 'Hot Weather'
      # no action
    elsif self.title == 'Good Weather'
      game.cow.welfare += 1
      game.cow.save
    elsif self.title == 'Mad Cow Crisis'
      ingredient_cats = game.ingredient_cats
      ingredient_cats.each do |ingredient_cat|
        ingredient_cat.meat_score -= 1
        ingredient_cat.save
      end
    end
  end

  def makeInactive(game)
    # when the event is finished
    if self.title == 'Cold Weather'
      ingredient_cats = game.ingredient_cats #IngredientCats.where(game_id: game.id)
      ingredient_cats.each do |ingredient_cat|
        ingredient_cat.milk_score += 1
        ingredient_cat.meat_score += 1
        ingredient_cat.muck_score += 1
        ingredient_cat.save
      end
    elsif self.title == 'Mad Cow Crisis'
      ingredient_cats = game.ingredient_cats #IngredientCats.where(game_id: game.id)
      ingredient_cats.each do |ingredient_cat|
        ingredient_cat.meat_score += 1
        ingredient_cat.save
      end
    end

  end
end
