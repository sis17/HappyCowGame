class Cow < ActiveRecord::Base
  has_one :game
  belongs_to :event, foreign_key: 'disease_id'
  belongs_to :event, foreign_key: 'weather_id'

  def oligos_score
    if self.oligos_marker == 0
      return 10
    elsif self.oligos_marker == 1
      return 2
    else
      return 0
    end
  end

  def as_json(options={})
    super(
      :include=> [
        :game
      ]
    )
  end
end
