class Cow < ActiveRecord::Base
  has_one :game
  belongs_to :event, foreign_key: 'disease_id'
  belongs_to :event, foreign_key: 'weather_id'

  def turn_effects
    #ph_marker
    if self.ph_marker >= 7.4
      self.welfare -= 1
    elsif self.ph_marker <= 5.4
      self.welfare -= 1
    end

    #body_condition
    if self.body_condition == 3 || self.body_condition <= -2
      self.welfare -= 1
    elsif self.body_condition == 2
      self.welfare += 1
    end
    self.save
    self.check_dead
  end

  def check_dead
    if (self.welfare < -6 and self.body_condition < -3)
      self.game.stage = 4
      self.game.save
      # make notice
      return true
    end
    return false
  end

  def oligos_score
    if self.oligos_marker == 0
      return 10
    elsif self.oligos_marker == 1
      return 2
    else
      return 0
    end
  end

  def increase_oligos(type)
    self.oligos_marker += 1
    self.save
  end

  def increase_muck_marker(amount)
    self.muck_marker += amount
    if self.muck_marker == 3 || self.muck_marker >= 5
      self.welfare -= 1
    end
    self.save
  end

  def increase_oligos_marker(amount)
    self.oligos_marker += amount

    self.save
  end

  def increase_welfare(amount)
    return self.set_welfare(self.welfare+amount)
  end
  def decrease_welfare(amount)
    return self.set_welfare(self.welfare-amount)
  end
  def set_welfare(amount)
    if amount < 3
      self.welfare = amount
      self.save
    end
    self.check_dead
    return self.welfare
  end

  def increase_ph_marker(amount)
    return self.set_ph_marker(self.ph_marker + (amount / 5))
  end
  def decrease_ph_marker(amount)
    return self.set_ph_marker(self.ph_marker - (amount / 5))
  end
  def set_ph_marker(amount)
    if amount < 7.6 and amount > 5
      self.ph_marker = amount
      self.save
    end
    return self.ph_marker
  end

  def set_body_condition(amount)
    if amount > 3
      amount = 3
    end
    self.body_condition = amount
    self.save
    self.check_dead
  end

  def check_constipated
    event = Event.where(id:self.disease_id).first
    if event
      return event.title == 'Constipation'
    end
    return false
  end

  def kill
    self.game.stage = 3
    self.game.save
  end

  def as_json(options={})
    super(
      :include=> [
        :game
      ]
    )
  end
end
