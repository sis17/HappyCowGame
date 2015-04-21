
class Cow < ActiveRecord::Base
  has_one :game
  belongs_to :event, foreign_key: 'disease_id'
  belongs_to :event, foreign_key: 'weather_id'

  def turn_effects
    #check water and energy in the rumen
    water = 0
    energy = 0
    rumen_water = Ingredient.joins(:ration => [:game_user, :position]).joins(:ingredient_cat)
      .where('game_users.game_id = ? and ingredient_cats.name = "water" and positions.area_id = 3', self.game.id).count
    rumen_energy = Ingredient.joins(:ration => [:game_user, :position]).joins(:ingredient_cat)
      .where('game_users.game_id = ? and ingredient_cats.name = "energy" and positions.area_id = 3', self.game.id).count
    # if water is greater, increase, otherwise decrease the ph
    self.increase_ph_marker(rumen_water - rumen_energy)

    #ph_marker
    if self.ph_marker >= 7.4
      self.decrease_welfare(1)
    elsif self.ph_marker <= 5.4
      self.decrease_welfare(1)
    end

    #body_condition
    if self.body_condition >= 3 or self.body_condition <= -2
      self.decrease_welfare(1)
    elsif self.body_condition == 2
      self.increase_welfare(1)
    end

    self.save
    self.check_dead
  end

  def check_dead
    if self.welfare < -6 or self.body_condition < -3
      self.kill
      # make notice
      return true
    end
    return false
  end

  def oligos_score
    return 10 if self.oligos_marker <= 0
    return 2 if self.oligos_marker == 1
    return 0
  end

  def increase_muck_marker(amount)
    self.muck_marker += amount
    if self.muck_marker == 3 || self.muck_marker >= 5
      self.decrease_welfare(1)
    end
    self.save
  end

  def increase_oligos_marker(amount)
    self.set_oligos_marker(self.oligos_marker + amount)
  end
  def set_oligos_marker(amount)
    self.oligos_marker = amount
    self.decrease_welfare(1) if self.oligos_score >= 2

    ing_cat = IngredientCat.where(game_id: self.game.id, name: 'oligos').take
    ing_cat.meat_score = self.oligos_score
    ing_cat.milk_score = self.oligos_score
    ing_cat.save
    
    self.save
  end

  def increase_welfare(amount)
    return self.set_welfare(self.welfare+amount)
  end
  def decrease_welfare(amount)
    return self.set_welfare(self.welfare-amount)
  end
  def set_welfare(amount)
    amount = 5 if amount > 5
    self.welfare = amount
    self.save
    self.check_dead
    return self.welfare
  end

  def increase_ph_marker(amount)
    return self.set_ph_marker(self.ph_marker + amount / 5.0)
  end
  def decrease_ph_marker(amount)
    return self.set_ph_marker(self.ph_marker - amount / 5.0)
  end
  def set_ph_marker(amount)
    # set max and min
    amount = 7.6 if amount > 7.6
    amount = 5 if amount < 5
    self.ph_marker = amount.round(1)
    self.save
    return self.ph_marker
  end

  def increase_body_condition(amount)
    return self.set_body_condition(self.body_condition+amount)
  end
  def decrease_body_condition(amount)
    return self.set_body_condition(self.body_condition-amount)
  end
  def set_body_condition(amount)
    amount = 3 if amount > 3
    self.body_condition = amount
    self.save
    self.check_dead
  end

  def check_constipated
    return Event.where(id:self.disease_id, uri: 'dis_con').count > 0
  end

  def check_mad
    return Event.where(id:self.disease_id, uri: 'dis_mad').count > 0
  end

  def check_diarrhea
    return Event.where(id:self.disease_id, uri: 'dis_dir').count > 0
  end

  def check_cold
   return Event.where(id:self.weather_id, uri: 'wth_cld').count > 0
  end

  def check_hot
   return Event.where(id:self.weather_id, uri: 'wth_hot').count > 0
  end

  def kill
    game = self.game
    game.stage = 4
    game.save
  end

  def change_event(event)
    if event.category == 'disease'
      existing_event = Event.where(id: self.disease_id).first
      if existing_event
        existing_event.makeInactive(self.game)
      end
      self.disease_id = event.id

    elsif event.category == 'weather'
      existing_event = Event.where(id: self.weather_id).first
      if existing_event
        existing_event.makeInactive(self.game)
      end
      self.weather_id = event.id

    elsif event.category == 'pregnancy' # switch on off
      self.pregnancy_id = if self.pregnancy_id then nil else event.id end
    end

    self.save
  end

  def as_json(options={})
    super(
      :include=> [
        :game
      ]
    )
  end
end
