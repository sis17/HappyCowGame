class Event < ActiveRecord::Base
  has_one :round

  def makeActive(game)
    cow = game.cow

    # make changes if it's a disease, weather or pregnancy event
    cow.change_event(self)

    # when the event begins
    if self.uri == 'dis_con'
      game.cow.decrease_welfare(1)
    elsif self.uri == 'dis_dir'
      game.cow.decrease_welfare(1)
    elsif self.uri == 'wth_cld'
      # no action
    elsif self.uri == 'wth_hot'
      # no action
    elsif self.uri == 'wth_gdw'
      game.cow.increase_welfare(1)
    elsif self.uri == 'dis_mad'
      ingredient_cats = game.ingredient_cats
      ingredient_cats.each do |ingredient_cat|
        ingredient_cat.meat_score -= 1
        ingredient_cat.save
      end
    end
  end

  def makeInactive(game)
    # when the event is finished
    if self.uri == 'dis_mad'
      ingredient_cats = game.ingredient_cats
      ingredient_cats.each do |ingredient_cat|
        ingredient_cat.meat_score += 1
        ingredient_cat.save
      end
    end

  end
end
